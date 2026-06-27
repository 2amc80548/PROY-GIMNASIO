 import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { MembersModule } from './members.module';

async function bootstrap() {
  const app = await NestFactory.create(MembersModule);
  
  // Permiso para el Frontend (CORS)
  app.enableCors();
  
  const port = Number(process.env.MEMBERS_HTTP_PORT ?? 3000);

  await app.listen(port);
  Logger.log(`Members HTTP escuchando en http://localhost:${port}`, 'Bootstrap');
}

bootstrap();