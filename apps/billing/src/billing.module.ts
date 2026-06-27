import { Module } from '@nestjs/common';
import { NotificationsController } from './billing.controller';
import { NotificationsService } from './billing.service';

@Module({
  controllers: [NotificationsController],
  providers: [NotificationsService],
})
export class BillingModule {}
