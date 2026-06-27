import { Controller, Logger } from '@nestjs/common';
import { EventPattern, Payload } from '@nestjs/microservices';
import { BillingService } from './billing.service';

@Controller()
export class BillingController {
  private readonly logger = new Logger(BillingController.name);

  constructor(private readonly billingService: BillingService) {}

  // Escucha exactamente el evento de members
  @EventPattern('member.registered')
  async handleMemberRegistered(@Payload() socio: any) {
    this.logger.log(`¡Alerta! Nuevo socio detectado desde NATS: ${socio.nombre}`);
    
    // Le pasamos los datos del socio para que procese el cobro
    await this.billingService.procesarPago(socio);
  }
}