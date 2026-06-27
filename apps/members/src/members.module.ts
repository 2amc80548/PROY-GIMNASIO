import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NATS_SERVICE, DEFAULT_NATS_URL } from '@app/contracts';
import { MembersController } from './members.controller';
import { MembersService } from './members.service';
import { Member } from './member.entity';

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
      host: 'localhost',
      port: 3306,
      username: 'root',
      password: 'admin',
      database: 'gimnasio_db',
      entities: [Member],
      synchronize: true, // Crea la tabla automáticamente
    }),
    TypeOrmModule.forFeature([Member]),
  ],
  controllers: [MembersController],
  providers: [MembersService],
})
export class MembersModule {}