// Eventos publicados por `billing` luego de procesar el cobro mensual.
// `access-control` los escucha para decidir si habilita o bloquea el acceso.
export const PAYMENT_CHARGED_EVENT = 'payment.charged';
export const PAYMENT_FAILED_EVENT = 'payment.failed';

export interface PaymentChargedEvent {
  memberId: string;
  paymentId: string;
  amount: number;
  chargedAt: string;
}

export interface PaymentFailedEvent {
  memberId: string;
  reason: string;
  failedAt: string;
}
