import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { Redis } from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  public client: Redis;

  onModuleInit() {
    this.client = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
  }

  onModuleDestroy() {
    this.client.disconnect();
  }

  async setOneTimePayload(id: string, payload: any, ttlSeconds: number = 3600) {
    await this.client.set(id, JSON.stringify(payload), 'EX', ttlSeconds);
  }

  async getAndConsumePayload(id: string): Promise<any | null> {
    // Lua script for atomic get-and-delete
    const lua = `
      local val = redis.call('get', KEYS[1])
      if val then
        redis.call('del', KEYS[1])
        return val
      end
      return nil
    `;
    const result = await this.client.eval(lua, 1, id);
    if (!result) return null;
    return JSON.parse(result as string);
  }
}
