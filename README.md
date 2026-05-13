# 🎫 GestiónTech — Sistema Integral de Gestión de Tickets

[![Flutter Version](https://img.shields.io/badge/Flutter-3.38.0-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.10.0-blue.svg)](https://dart.dev)

Un sistema integral de gestión de tickets técnicos con un enfoque en **UI/UX moderna y animaciones fluidas**. Desarrollado para ofrecer una experiencia de usuario excepcional, este frontend se integra de manera robusta con un backend en Node.js, garantizando un flujo de trabajo eficiente, seguro y escalable.

> ⚠️ **Nota:** El proyecto se encuentra en desarrollo activo. Esta documentación será ampliada conforme se definan nuevas funcionalidades.

---

## 🚀 Versiones de Desarrollo

Para garantizar la compatibilidad entre el equipo de desarrollo, se utilizan estrictamente las siguientes versiones:

| Herramienta | Versión | Canal |
| :--- | :--- | :--- |
| **Flutter** | `3.38.0` | Stable |
| **Dart** | `3.10.0` | — |

---

## 🛠️ Stack Tecnológico

| Tecnología | Descripción |
| :--- | :--- |
| **📱 Frontend** | Desarrollado con Flutter & Dart. |
| **🔐 Autenticación** | Firebase Google Sign-In y sistema propio basado en JWT (JSON Web Tokens). |
| **⚙️ Backend** | Node.js API (Puerto `3005`). |
| **💾 Persistencia** | SharedPreferences para el manejo eficiente y local de sesiones de usuario. |

---

## 🏗️ Arquitectura y Estructura (`lib/`)

El proyecto implementa una arquitectura **Feature-First (orientada a funcionalidades)**, la cual agrupa el código por módulos de negocio, facilitando la escalabilidad y el trabajo en equipo.

### Módulos Principales
* **🔐 `features/auth/`**: Pantallas de Login, Registro, Verificación de Código y Recuperación de Contraseña.
* **🎫 `features/tickets/`**: Gestión de tickets (Home, Agregar Ticket) con filtros por prioridad y búsqueda.
* **👤 `features/profile/`**: Perfil de usuario con gestión de datos (Teléfono, Dirección, Nombre) conectados al backend.
* **❓ `features/help_center/`**: FAQ, Guía de usuario paso a paso y Políticas de privacidad.
* **🧩 `widgets/`**: Componentes reutilizables (Botones animados, engranajes rotatorios, tarjetas de tickets, drawer personalizado).
* **🎨 `utils/`** y **`core/`**: Definición de paleta de colores (`AppColors`), constantes globales y lógica compartida.

### Estructura Interna por Módulo
Cada funcionalidad dentro de `features/` sigue un patrón organizado para separar responsabilidades:
```text
feature_name/
├── models/           # Mapeo de datos (JSON to Dart)
├── screens/          # Pantallas completas del módulo
├── services/         # Peticiones HTTP específicas (API)
└── widgets/          # Componentes visuales únicos de este módulo
```

---

## ✨ Funcionalidades Destacadas

* **🎭 Animaciones y Feedback Visual Premium**: Animaciones de entrada personalizadas y feedback visual (como la *Shake animation*) en formularios para maximizar la interactividad.
* **👥 Sistema de Roles Inteligente**: Gestión del estatus de tickets diferenciada por perfiles (Admin / Usuario).
* **⚙️ Diseño Dinámico Inmersivo**: Fondo visualmente atractivo con engranajes animados que rotan, optimizados mediante aceleración por hardware.

---

## 💻 Instalación y Configuración

Sigue estos pasos para desplegar el entorno en tu máquina local:

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/TuUsuario/frontend-tickets-flutter.git
   cd frontend-tickets-flutter/app_tickets
   ```

2. **Obtener las dependencias del proyecto:**
   ```bash
   flutter pub get
   ```

3. **Configurar IP del backend (Importante para emuladores)**
   Si tu backend en Node.js corre en local (puerto `3005`) y estás probando en el **emulador de Android**, recuerda que `localhost` no funciona. Debes apuntar a la IP especial del emulador:
   ```text
   http://10.0.2.2:3005
   ```
   *Para dispositivos físicos o iOS, utiliza la IP real de tu máquina en la red local (ej. `192.168.1.X`).*

4. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

---

## 👥 Equipo de Desarrollo

| Nombre | Rol |
| :--- | :--- |
| **Héctor Badillo García** | Arquitectura y lógica de integración |
| **Stefany Ausencio Lopez** | Diseño de interfaces y maquetado |

---

## 📄 Licencia

Este proyecto es parte de un proceso académico (estadías) y no está destinado para uso comercial sin la autorización expresa del equipo desarrollador.