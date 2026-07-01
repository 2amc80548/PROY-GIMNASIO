import { Inject, Injectable, Logger } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { NATS_SERVICE } from '@app/contracts';

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);

  // Inyectamos NATS
  constructor(@Inject(NATS_SERVICE) private readonly nats: ClientProxy) {}


  procesarPago(socio: { id: number; nombre: string; plan: string }) {
    this.logger.log(`Cobrando mensualidad al socio: ${socio.nombre} (ID: ${socio.id}) - Plan: ${socio.plan}`);

    // Simulador de pasarela de pago 
    const pagoExitoso = Math.random() > 0.5;

    if (pagoExitoso) {
      this.logger.log(`✅ Pago EXITOSO para ${socio.nombre}`);
      // Avisamos al resto del sistema que el pago pasó
      this.nats.emit('payment.charged', socio);
    } else {
      this.logger.warn(`❌ Pago RECHAZADO para ${socio.nombre} (Fondos insuficientes)`);
      // Avisamos al resto del sistema que el pago falló
      this.nats.emit('payment.failed', socio);
    }
  }
}