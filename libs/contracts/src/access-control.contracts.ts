// Eventos publicados por `access-control` luego de decidir el acceso del socio.
// `members` los escucha para reflejar el estado de membresía en el CRUD.
export const ACCESS_GRANTED_EVENT = 'access.granted';
export const ACCESS_BLOCKED_EVENT = 'access.blocked';

export interface AccessGrantedEvent {
  memberId: string;
  grantedAt: string;
}

export interface AccessBlockedEvent {
  memberId: string;
  reason: string;
  blockedAt: string;
}