import { Controller, Logger } from '@nestjs/common';
import { EventPattern, Payload } from '@nestjs/microservices';
import { BillingService } from './billing.service';

@Controller()
export class BillingController {
  private readonly logger = new Logger(BillingController.name);

  constructor(private readonly billingService: BillingService) {}

  // Escucha exactamente el evento de members
@EventPattern('member.registered')
  handleMemberRegistered(@Payload() data: { id: number; nombre: string; plan: string }) {
    this.billingService.procesarPago(data);
  }
}