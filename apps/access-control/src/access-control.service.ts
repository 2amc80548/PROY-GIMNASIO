import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AccessControlService {
  private readonly logger = new Logger(AccessControlService.name);

  concederAcceso(socio: any) {
    this.logger.log(`🟢 TORNIQUETE DESBLOQUEADO: Bienvenido al gimnasio, ${socio.nombre}.`);
  }

  denegarAcceso(socio: any) {
    this.logger.warn(`🔴 TORNIQUETE BLOQUEADO: Acceso denegado para ${socio.nombre}. Pago pendiente.`);
  }
}