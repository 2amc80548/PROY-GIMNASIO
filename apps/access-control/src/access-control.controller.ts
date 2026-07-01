import { Controller } from '@nestjs/common';
import { EventPattern, Payload } from '@nestjs/microservices';
import { AccessControlService } from './access-control.service';

@Controller()
export class AccessControlController {
  constructor(private readonly accessControlService: AccessControlService) {}

  // Escucha si el pago fue un éxito
@EventPattern('payment.charged')
  handlePaymentCharged(@Payload() data: { nombre: string }) {
    this.accessControlService.concederAcceso(data);
  }

@EventPattern('payment.failed')
  handlePaymentFailed(@Payload() data: { nombre: string }) {
    this.accessControlService.denegarAcceso(data);
  }
}