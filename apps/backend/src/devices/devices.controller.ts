import { Controller, Post, Get, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RegisterDeviceDto } from './dto/register-device.dto';

@Controller('devices')
@UseGuards(JwtAuthGuard)
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Post('register')
  async registerDevice(@Request() req: any, @Body() body: RegisterDeviceDto) {
    return this.devicesService.registerDevice(req.user.userId, body);
  }

  @Get()
  async getMyDevices(@Request() req: any) {
    return this.devicesService.getMyDevices(req.user.userId);
  }

  @Delete(':deviceId')
  async revokeDevice(@Request() req: any, @Param('deviceId') deviceId: string) {
    await this.devicesService.revokeDevice(req.user.userId, deviceId);
    return { success: true };
  }
}
