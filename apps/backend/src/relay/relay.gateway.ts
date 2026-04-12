import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { RedisService } from '../redis/redis.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class RelayGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  // Track connected devices: deviceId -> socketId
  private connectedDevices = new Map<string, string>();

  constructor(
    private jwtService: JwtService,
    private redisService: RedisService,
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth.token?.split(' ')[1] || client.handshake.headers.authorization?.split(' ')[1];
      if (!token) {
        client.disconnect();
        return;
      }
      
      const payload = this.jwtService.verify(token, { secret: process.env.JWT_SECRET || 'super-secret-jwt-key' });
      const deviceId = client.handshake.query.deviceId as string;
      
      if (!deviceId) {
        client.disconnect();
        return;
      }

      this.connectedDevices.set(deviceId, client.id);
      
      // Check for pending messages in Redis
      const pendingMessages = await this.redisService.getAndConsumePayload(`pending_messages:${deviceId}`);
      if (pendingMessages) {
        client.emit('pending_messages', pendingMessages);
      }
    } catch (e) {
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    for (const [deviceId, socketId] of this.connectedDevices.entries()) {
      if (socketId === client.id) {
        this.connectedDevices.delete(deviceId);
        break;
      }
    }
  }

  @SubscribeMessage('relay_message')
  async handleRelayMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { toDeviceId: string; messagePayload: any },
  ) {
    const targetSocketId = this.connectedDevices.get(payload.toDeviceId);

    if (targetSocketId) {
      this.server.to(targetSocketId).emit('receive_message', payload.messagePayload);
    } else {
      const key = `pending_messages:${payload.toDeviceId}`;
      const existing = await this.redisService.client.get(key);
      const messages = existing ? JSON.parse(existing) : [];
      messages.push(payload.messagePayload);
      await this.redisService.setOneTimePayload(key, messages, 86400);
    }
  }

  @SubscribeMessage('rtc_offer')
  async handleRtcOffer(@ConnectedSocket() client: Socket, @MessageBody() payload: { toDeviceId: string; offer: any; fromDeviceId: string }) {
    const targetSocketId = this.connectedDevices.get(payload.toDeviceId);
    if (targetSocketId) {
      this.server.to(targetSocketId).emit('rtc_offer', { offer: payload.offer, fromDeviceId: payload.fromDeviceId });
    }
  }

  @SubscribeMessage('rtc_answer')
  async handleRtcAnswer(@ConnectedSocket() client: Socket, @MessageBody() payload: { toDeviceId: string; answer: any; fromDeviceId: string }) {
    const targetSocketId = this.connectedDevices.get(payload.toDeviceId);
    if (targetSocketId) {
      this.server.to(targetSocketId).emit('rtc_answer', { answer: payload.answer, fromDeviceId: payload.fromDeviceId });
    }
  }

  @SubscribeMessage('rtc_ice_candidate')
  async handleIceCandidate(@ConnectedSocket() client: Socket, @MessageBody() payload: { toDeviceId: string; candidate: any; fromDeviceId: string }) {
    const targetSocketId = this.connectedDevices.get(payload.toDeviceId);
    if (targetSocketId) {
      this.server.to(targetSocketId).emit('rtc_ice_candidate', { candidate: payload.candidate, fromDeviceId: payload.fromDeviceId });
    }
  }
}
