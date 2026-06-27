import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity('members')
export class Member {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  nombre: string;

  @Column({ unique: true })
  email: string;

  @Column()
  plan: string;

  @Column({ default: 'Pendiente' })
  estado_pago: string;
}