// Evento publicado por `members` cuando un socio se inscribe a un plan.
// `billing` lo escucha para generar el cobro de la primera mensualidad.
export const MEMBER_REGISTERED_EVENT = 'member.registered';

export interface MemberRegisteredEvent {
  memberId: string;
  name: string;
  planId: string;
  amount: number;
  registeredAt: string;
}
