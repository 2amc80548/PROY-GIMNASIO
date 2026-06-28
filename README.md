🏋️‍♂️ Backend - Gestión de Gimnasio (Grupo 3)

Este es el backend de nuestra arquitectura de microservicios orientada a eventos para el control de acceso a un gimnasio.

El sistema consta de 3 microservicios comunicados por NATS y respaldados por una base de datos MySQL local:

members (HTTP): Administra el CRUD de socios y publica el evento cuando alguien se inscribe.
billing (Worker): Escucha el registro, simula el cobro de la mensualidad (80% éxito / 20% fallo) y publica el resultado.
access-control (Worker): Escucha el resultado del pago y simula físicamente habilitar o bloquear el torniquete del gimnasio.


🛠️ Requisitos Previos 

Antes de empezar, asegúrate de tener instalado en tu computadora:

Docker y Docker Compose (Para levantar la base de datos y el broker NATS).
Node.js (Versión 20 o superior).
🚀 Cómo encender el proyecto localmente (Paso a paso)

Paso 1: Actualizar el código

Asegúrate de estar en la rama main y tener la última versión del código:

git checkout main
git pull origin main


Paso 2: Levantar la Infraestructura (Docker)

En la raíz del proyecto, enciende MySQL, NATS  ejecutando:

docker compose up -d

Espera unos segundos a que los contenedores inicien correctamente.

Paso 3: Instalar dependencias

Instala todas las librerías necesarias de NestJS ejecutando en la raíz:

npm install

Paso 4: Encender los Microservicios 

Para ver cómo se comunican entre sí, necesitas abrir 3 terminales distintas en la raíz del proyecto y ejecutar un microservicio en cada una:

Terminal 1 (El Mesero):

npm run start:members

Terminal 2 (El Chef):

npm run start:billing

Terminal 3 (El Guardia):

npm run start:access-control
✅ Verificación

Sabrás que todo está bien cuando las 3 terminales muestren mensajes en VERDE sin errores.
--------------------------------------------------------------------------

Para probar que todo funciona, usa Postman o Thunder Client 

Haz una petición POST a http://localhost:3000/members.

En el Body (Formato JSON), envía un nuevo mienbro. (Nota: El email debe ser único cada vez):

JSON
{
  "nombre": "Juan Perez",
  "email": "juan.perez.1@gmail.com",
  "plan": "Mensual Premium"
}
Presiona Send.

¿Qué deberías ver en las terminales?
Mira tus 3 terminales y verás el flujo en tiempo real:

members guardará al socio en MySQL y gritará member.registered.

billing escuchará, cobrará y gritará payment.charged o payment.failed.

access-control escuchará el cobro y mostrará 🟢 TORNIQUETE DESBLOQUEADO o 🔴 TORNIQUETE BLOQUEADO.