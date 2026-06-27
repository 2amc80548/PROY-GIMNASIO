import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { AccessControlModule } from './access-control.module';
import { DEFAULT_NATS_URL } from '@app/contracts';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(AccessControlModule, {
    transport: Transport.NATS,
    options: {
      servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
    },
  });

  await app.listen();
  Logger.log('Access Control vigilando el torniquete vía NATS', 'Bootstrap');
}

bootstrap();