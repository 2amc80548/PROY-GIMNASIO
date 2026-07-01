import { Controller, Logger } from '@nestjs/common';
import { EventPattern, Payload } from '@nestjs/microservices';
import { MembersService } from './members.service';

@Controller()
export class PaymentEventsController {
  private readonly logger = new Logger(PaymentEventsController.name);

  constructor(private readonly membersService: MembersService) {
    this.logger.log('🟢 PaymentEventsController instanciado correctamente');
  }

  @EventPattern('payment.charged')
  async handlePaymentCharged(@Payload() socio: { id: number }) {
    this.logger.log(`🔔 EVENTO RECIBIDO payment.charged: ${JSON.stringify(socio)}`);
    await this.membersService.actualizarEstadoPago(socio.id, 'Pagado');
  }

  @EventPattern('payment.failed')
  async handlePaymentFailed(@Payload() socio: { id: number }) {
    this.logger.log(`🔔 EVENTO RECIBIDO payment.failed: ${JSON.stringify(socio)}`);
    await this.membersService.actualizarEstadoPago(socio.id, 'Rechazado');
  }
}