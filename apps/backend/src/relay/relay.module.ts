import { Module } from '@nestjs/common';
import { RelayGateway } from './relay.gateway';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'super-secret-jwt-key',
    }),
  ],
  providers: [RelayGateway],
})
export class RelayModule {}
