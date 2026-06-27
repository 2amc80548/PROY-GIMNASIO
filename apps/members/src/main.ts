import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { MembersModule } from './members.module';

async function bootstrap() {
  const app = await NestFactory.create(MembersModule);
  const port = Number(process.env.ORDERS_HTTP_PORT ?? 3000);

  await app.listen(port);
  Logger.log(`members HTTP escuchando en http://localhost:${port}`, 'Bootstrap');
}

bootstrap();
