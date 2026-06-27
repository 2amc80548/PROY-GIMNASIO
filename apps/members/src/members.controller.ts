import { Body, Controller, Get, Post, Param, Patch, Delete } from '@nestjs/common';
import { MembersService } from './members.service';

@Controller('members')
export class MembersController {
  constructor(private readonly membersService: MembersService) {}

  // Crear
  @Post()
  create(@Body() dto: any) {
    return this.membersService.createMember(dto);
  }

  // Leer todos
  @Get()
  findAll() {
    return this.membersService.findAll();
  }

  // Actualizar un socio específico por su ID
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: any) {
    // El símbolo '+' convierte el id de string a número
    return this.membersService.update(+id, dto);
  }

  // Eliminar un socio específico por su ID
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.membersService.remove(+id);
  }
}