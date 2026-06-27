import { Controller } from '@nestjs/common';
import { EventPattern, Payload } from '@nestjs/microservices';
import { AccessControlService } from './access-control.service';

@Controller()
export class AccessControlController {
  constructor(private readonly accessControlService: AccessControlService) {}

  // Escucha si el pago fue un éxito
  @EventPattern('payment.charged')
  handlePagoExitoso(@Payload() socio: any) {
    this.accessControlService.concederAcceso(socio);
  }

  // Escucha si el pago falló
  @EventPattern('payment.failed')
  handlePagoRechazado(@Payload() socio: any) {
    this.accessControlService.denegarAcceso(socio);
  }
}