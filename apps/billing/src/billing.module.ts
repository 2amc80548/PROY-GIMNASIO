import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { NATS_SERVICE, DEFAULT_NATS_URL } from '@app/contracts';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';

@Module({   
  imports: [
    // publicar eventos en NATS
    ClientsModule.register([
      {
        name: NATS_SERVICE,
        transport: Transport.NATS,
        options: {
          servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
        },
      },
    ]),
  ],
  controllers: [BillingController],
  providers: [BillingService],
})
export class BillingModule {}