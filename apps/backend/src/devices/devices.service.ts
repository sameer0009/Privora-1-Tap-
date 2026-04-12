import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DevicesService {
  constructor(private prisma: PrismaService) {}

  async registerDevice(userId: string, body: { deviceId: string, publicKey: string, keyExchangeBase: string, deviceName?: string }) {
    // Check if deviceId already exists for this user
    const existing = await this.prisma.device.findUnique({
      where: { deviceId: body.deviceId }
    });

    if (existing) {
      if (existing.userId !== userId) {
        throw new BadRequestException('Device already registered to another user');
      }
      return existing; // Idempotent
    }

    return this.prisma.device.create({
      data: {
        userId,
        deviceId: body.deviceId,
        publicKey: body.publicKey,
        keyExchangeBase: body.keyExchangeBase,
        deviceName: body.deviceName || 'Unknown Device',
      }
    });
  }

  async getMyDevices(userId: string) {
    return this.prisma.device.findMany({
      where: { userId },
      select: {
        id: true,
        deviceId: true,
        deviceName: true,
        publicKey: true,
        isActive: true,
        lastSeen: true,
      }
    });
  }

  async revokeDevice(userId: string, deviceId: string) {
    return this.prisma.device.delete({
      where: { deviceId, userId }
    });
  }
}
