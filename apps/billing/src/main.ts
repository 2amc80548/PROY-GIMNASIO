import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { BillingModule } from './billing.module';
import { DEFAULT_NATS_URL } from '@app/contracts';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(BillingModule, {
    transport: Transport.NATS,
    options: {
      servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
    },
  });

  await app.listen();
  Logger.log('billing escuchando eventos NATS', 'Bootstrap');
}

bootstrap().catch(err => console.error(err));
