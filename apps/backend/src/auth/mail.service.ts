import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private transporter: nodemailer.Transporter;

  constructor(private configService: ConfigService) {
    this.transporter = nodemailer.createTransport({
      host: this.configService.get<string>('SMTP_HOST', 'smtp.gmail.com'),
      port: this.configService.get<number>('SMTP_PORT', 587),
      secure: false, // true for 465, false for other ports
      auth: {
        user: this.configService.get<string>('SMTP_USER'),
        pass: this.configService.get<string>('SMTP_PASS'),
      },
    });
  }

  async sendVerificationEmail(email: string, token: string) {
    const url = `${this.configService.get<string>('FRONTEND_URL', 'http://localhost:3000')}/verify-email?token=${token}`;
    
    await this.transporter.sendMail({
      from: '"Privora Secure" <no-reply@privora.io>',
      to: email,
      subject: 'Verify your Privora Vault',
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #00FF66;">Welcome to Privora Secure</h2>
          <p>Your zero-retention vault is almost ready. Please click the button below to verify your identity.</p>
          <a href="${url}" style="display: inline-block; padding: 10px 20px; background-color: #00FF66; color: black; text-decoration: none; border-radius: 5px; font-weight: bold;">VERIFY VAULT</a>
          <p style="margin-top: 20px; color: #777; font-size: 12px;">If you did not request this, please ignore this email.</p>
        </div>
      `,
    });
  }

  async sendOTP(email: string, otp: string) {
    await this.transporter.sendMail({
      from: '"Privora Secure" <no-reply@privora.io>',
      to: email,
      subject: 'Your Security Code',
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #00FF66;">Security Verification</h2>
          <p>Use the following code to complete your action. This code will expire in 10 minutes.</p>
          <h1 style="letter-spacing: 5px; text-align: center; color: #00FF66;">${otp}</h1>
        </div>
      `,
    });
  }
}
