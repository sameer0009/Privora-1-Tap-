import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class RegisterDeviceDto {
  @IsString()
  @IsNotEmpty()
  deviceId: string;

  @IsString()
  @IsNotEmpty()
  publicKey: string;

  @IsString()
  @IsNotEmpty()
  keyExchangeBase: string;

  @IsString()
  @IsOptional()
  deviceName?: string;
}
