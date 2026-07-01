import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NATS_SERVICE, DEFAULT_NATS_URL } from '@app/contracts';
import { MembersController } from './members.controller';
import { MembersService } from './members.service';
import { Member } from './member.entity';
import { PaymentEventsController } from './payment-events.controller';

@Module({
  imports: [
    // 1. Conexión a NATS (De la plantilla oficial)
    ClientsModule.register([
      {
        name: NATS_SERVICE,
        transport: Transport.NATS,
        options: {
          servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
        },
      },
    ]),
    // 2. Conexión a MySQL local
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST || 'localhost',
      port: 3306,
      username: process.env.DB_USERNAME || 'root',
      password: process.env.DB_PASSWORD || 'admin', // contraseña local
      database: process.env.DB_NAME || 'gimnasio_db',
      entities: [Member],
      synchronize: true,
    }),
    TypeOrmModule.forFeature([Member]),
  ],
  controllers: [MembersController, PaymentEventsController],
  providers: [MembersService],
})
export class MembersModule {}