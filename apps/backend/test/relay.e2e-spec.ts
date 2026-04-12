import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';
import { RedisService } from './../src/redis/redis.service';

describe('Relay One-Time Consumption (E2E)', () => {
  let app: INestApplication;
  let redisService: RedisService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    redisService = moduleFixture.get<RedisService>(RedisService);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('Atomic Zero-Retention: Should delete message immediately after first read', async () => {
    const messageId = 'test_msg_123';
    const payload = { content: 'Secret data' };

    // 1. Store the one-time payload
    await redisService.setOneTimePayload(messageId, payload);

    // 2. Consume it for the first time
    const consumed = await redisService.getAndConsumePayload(messageId);
    expect(consumed).toEqual(payload);

    // 3. Attempt to consume it again immediately
    const secondAttempt = await redisService.getAndConsumePayload(messageId);
    
    // Industrial Requirement: Second read must be null (Atomically deleted)
    expect(secondAttempt).toBeNull();
  });

  it('TTL Expiry: Message should not be reachable after TTL', async () => {
    const messageId = 'expire_msg';
    const payload = { data: 'gone' };

    // Store with 1 second TTL
    await redisService.setOneTimePayload(messageId, payload, 1);
    
    // Wait for expiry
    await new Promise(resolve => setTimeout(resolve, 1100));

    const result = await redisService.getAndConsumePayload(messageId);
    expect(result).toBeNull();
  });
});
