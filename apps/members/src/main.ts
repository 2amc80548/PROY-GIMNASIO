import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { MembersModule } from './members.module';
import { DEFAULT_NATS_URL } from '@app/contracts';

async function bootstrap() {
  // 1. App HTTP (para el Frontend: CRUD de socios)
  const httpApp = await NestFactory.create(MembersModule);
  httpApp.enableCors();

  const port = Number(process.env.MEMBERS_HTTP_PORT ?? 3000);
  await httpApp.listen(port);
  Logger.log(`Members HTTP escuchando en http://localhost:${port}`, 'Bootstrap');

  // 2. App Microservicio NATS (para escuchar payment.charged / payment.failed)
  const microApp = await NestFactory.createMicroservice<MicroserviceOptions>(MembersModule, {
    transport: Transport.NATS,
    options: {
      servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
    },
  });
  await microApp.listen();
  Logger.log('Members también escuchando eventos NATS (payment.charged / payment.failed)', 'Bootstrap');
}

bootstrap().catch(err => console.error(err));