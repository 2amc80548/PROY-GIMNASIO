import { Module } from '@nestjs/common';
import { NotificationsController } from './access-control.controller';
import { NotificationsService } from './access-control.service';

@Module({
  controllers: [NotificationsController],
  providers: [NotificationsService],
})
export class NotificationsModule {}
