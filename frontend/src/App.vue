<script setup>
import { ref, onMounted } from 'vue';

const socios = ref([]);
const nuevoSocio = ref({ nombre: '', email: '', plan: 'Mensual Básico' });
const socioEditandoId = ref(null); // Variable para saber si estamos editando

const API_URL = 'http://localhost:3000/members';

const obtenerSocios = async () => {
  try {
    const respuesta = await fetch(API_URL);
    socios.value = await respuesta.json();
  } catch (error) {
    console.error("Error al obtener los socios:", error);
  }
};

// Función de doble uso: Crear o Actualizar
const guardarSocio = async () => {
  try {
    const url = socioEditandoId.value ? `${API_URL}/${socioEditandoId.value}` : API_URL;
    const metodo = socioEditandoId.value ? 'PATCH' : 'POST';

    const respuesta = await fetch(url, {
      method: metodo,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(nuevoSocio.value)
    });

    if (respuesta.ok) {
      alert(socioEditandoId.value ? "¡Socio actualizado!" : "¡Socio registrado con éxito!");
      cancelarEdicion(); // Limpiamos el formulario
      obtenerSocios(); // Refrescamos la tabla
    } else {
      alert("Error al guardar. Revisa los datos.");
    }
  } catch (error) {
    console.error("Error al guardar:", error);
  }
};

// Carga los datos a la cajita del formulario para editarlos
const prepararEdicion = (socio) => {
  socioEditandoId.value = socio.id;
  nuevoSocio.value = { nombre: socio.nombre, email: socio.email, plan: socio.plan };
};

const cancelarEdicion = () => {
  socioEditandoId.value = null;
  nuevoSocio.value = { nombre: '', email: '', plan: 'Mensual Básico' };
};

const eliminarSocio = async (id) => {
  if(confirm("¿Estás seguro de eliminar a este socio?")) {
    try {
      await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
      obtenerSocios();
    } catch (error) {
      console.error("Error al eliminar:", error);
    }
  }
};

onMounted(() => { obtenerSocios(); });
</script>

<template>
  <main class="contenedor">
    <h1>💪 Panel de Control del Gimnasio</h1>

    <div class="tarjeta">
      <h2>{{ socioEditandoId ? 'Editar Socio' : 'Inscribir Nuevo Socio' }}</h2>
      <form @submit.prevent="guardarSocio" class="formulario">
        <input type="text" v-model="nuevoSocio.nombre" placeholder="Nombre completo" required />
        <input type="email" v-model="nuevoSocio.email" placeholder="Correo electrónico" required :disabled="socioEditandoId" />
        <select v-model="nuevoSocio.plan" required>
          <option>Mensual Básico</option>
          <option>Mensual Premium</option>
          <option>Anual VIP</option>
        </select>
        
        <div class="botones-form">
          <button type="submit" class="btn-guardar">{{ socioEditandoId ? 'Actualizar' : 'Registrar Socio' }}</button>
          <button v-if="socioEditandoId" type="button" @click="cancelarEdicion" class="btn-cancelar">Cancelar</button>
        </div>
      </form>
    </div>

    <div class="tarjeta">
      <h2>Socios Registrados</h2>
      <table class="tabla-socios">
        <thead>
          <tr>
            <th>ID</th><th>Nombre</th><th>Email</th><th>Plan</th><th>Estado Pago</th><th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="socio in socios" :key="socio.id">
            <td>{{ socio.id }}</td><td>{{ socio.nombre }}</td><td>{{ socio.email }}</td><td>{{ socio.plan }}</td>
            <td>
              <span :class="socio.estado_pago === 'Pendiente' ? 'badge-pendiente' : 'badge-ok'">
                {{ socio.estado_pago }}
              </span>
            </td>
            <td class="acciones">
              <button @click="prepararEdicion(socio)" class="btn-editar">Editar</button>
              <button @click="eliminarSocio(socio.id)" class="btn-eliminar">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </main>
</template>

<style scoped>
.contenedor { font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; }
h1, p { text-align: center; color: #2c3e50; }
.tarjeta { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); margin-bottom: 20px; }
.formulario { display: flex; flex-direction: column; gap: 15px; }
input, select { padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 16px; }
.botones-form { display: flex; gap: 10px; }
.btn-guardar { background-color: #4CAF50; color: white; border: none; padding: 12px; border-radius: 4px; cursor: pointer; font-weight: bold; flex: 1; }
.btn-cancelar { background-color: #9e9e9e; color: white; border: none; padding: 12px; border-radius: 4px; cursor: pointer; flex: 1;}
.btn-editar { background-color: #2196F3; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; margin-right: 5px;}
.btn-eliminar { background-color: #f44336; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }
.tabla-socios { width: 100%; border-collapse: collapse; margin-top: 10px; }
th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
.badge-pendiente { background-color: #ff9800; color: white; padding: 4px 8px; border-radius: 12px; font-size: 12px; }
.badge-ok { background-color: #4CAF50; color: white; padding: 4px 8px; border-radius: 12px; font-size: 12px; }
.acciones { min-width: 130px; }
</style>