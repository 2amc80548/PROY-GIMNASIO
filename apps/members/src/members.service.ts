import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NATS_SERVICE } from '@app/contracts';
import { Member } from './member.entity';

@Injectable()
export class MembersService implements OnModuleInit {
  private readonly logger = new Logger(MembersService.name);

  constructor(
    @Inject(NATS_SERVICE) private readonly nats: ClientProxy,
    @InjectRepository(Member) private memberRepository: Repository<Member>,
  ) {}

  async onModuleInit() {
    await this.nats.connect();
    this.logger.log('Conectado al broker NATS');
  }

  // 1. Crear (POST)
  async createMember(dto: { nombre: string; email: string; plan: string }) {
    const nuevoSocio = this.memberRepository.create({
      nombre: dto.nombre,
      email: dto.email,
      plan: dto.plan,
    });
    
    const socioGuardado = await this.memberRepository.save(nuevoSocio);
    this.logger.log(`Guardado en MySQL: Socio ID ${socioGuardado.id}`);

    this.nats.emit('member.registered', socioGuardado);
    this.logger.log(`Publicado evento NATS: member.registered`);

    return socioGuardado;
  }

  // 2. Leer todos (GET)
  async findAll() {
    return this.memberRepository.find();
  }

  // 3. Actualizar (PATCH)
  async update(id: number, dto: { nombre?: string; email?: string; plan?: string }) {
    await this.memberRepository.update(id, dto);
    this.logger.log(`Socio actualizado en MySQL: ID ${id}`);
    // Busca y devuelve el socio ya actualizado
    return this.memberRepository.findOneBy({ id }); 
  }

  // 4. Eliminar (DELETE)
  async remove(id: number) {
    await this.memberRepository.delete(id);
    this.logger.log(`Socio eliminado en MySQL: ID ${id}`);
    return { message: `Socio con ID ${id} eliminado correctamente` };
  }

    // 5. Actualizar solo el estado de pago (llamado desde el listener de NATS)
  async actualizarEstadoPago(id: number, estado: string) {
    await this.memberRepository.update(id, { estado_pago: estado });
    this.logger.log(`estado_pago actualizado en MySQL: ID ${id} -> ${estado}`);
  }
}