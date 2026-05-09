# 🎫 Sistema de Gestión de Tickets — Aplicación Móvil

[![Flutter Version](https://img.shields.io/badge/Flutter-3.38.0-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.10.0-blue.svg)](https://dart.dev)

Aplicación móvil desarrollada en **Flutter** como parte del proceso de estadías. Este frontend consume una API REST personalizada para la gestión completa de tickets.

> ⚠️ **Nota:** El proyecto se encuentra en desarrollo activo. Esta documentación será ampliada conforme se definan nuevas funcionalidades.

---

## 🚀 Versiones de desarrollo

Para garantizar compatibilidad entre el equipo, se utilizan las siguientes versiones:

| Herramienta | Versión  | Canal     |
|-------------|----------|-----------|
| Flutter     | `3.38.0` | Stable    |
| Dart        | `3.10.0` | —         |

---

## 🏗️ Arquitectura del proyecto

Se ha implementado una arquitectura **Feature-First (orientada a funcionalidades)**. A diferencia de los enfoques tradicionales (como MVC o MVVM por capas técnicas), esta estrategia organiza el código por **módulos de negocio**, lo que facilita:

- El trabajo en equipo.
- La escalabilidad del proyecto.
- El mantenimiento a largo plazo.

### Estructura de carpetas

```text
lib/
├── core/                     # Lógica global compartida
│   ├── constants/            # URLs, colores y strings fijos
│   ├── network/              # Configuración de clientes HTTP (Fetch/Dio)
│   ├── theme/                # Estilos globales, fuentes y colores
│   └── utils/                # Validadores, formateadores, etc.
│
├── features/                 # Módulos independientes por funcionalidad
│   ├── auth/                 # Login, registro y recuperación de cuenta
│   ├── tickets/              # Listado, creación y gestión de tickets
│   └── profile/              # Perfil de usuario, dirección y teléfono
│
└── main.dart                 # Punto de entrada de la app
```

Estructura interna de cada módulo (features/*/)
Cada módulo de negocio contiene su propia organización interna:

```text
feature_name/
├── models/           # Mapeo de datos del backend
├── screens/          # Pantallas completas del módulo
├── services/         # Peticiones HTTP específicas del módulo
└── widgets/          # Componentes visuales reutilizables solo en el módulo
```

---
## 🛠️ Instalación y configuración
Sigue estos pasos para ejecutar el proyecto en tu entorno local.


1. Clonar el repositorio
    ```bash
    git clone https://github.com/TuUsuario/frontend-tickets-flutter.git
    ```
2. Obtener dependencias
    ```bash
    flutter pub get
    ```
3. Configurar IP del backend (importante para emuladores)
Si tu backend corre en localhost y usas el emulador de Android, recuerda cambiar la IP por la especial del emulador:

    ```text
    http://10.0.2.2:3000
    ```
    * Para dispositivos físicos o iOS, usa la IP real de tu máquina en la red local.


---
## 👥 Equipo de desarrollo
Nombre	Rol
Héctor Badillo García	Arquitectura y lógica de integración
Stefany	Diseño de interfaces y maquetado

| Nombre | Rol  |
|-------------|----------|
| Hector Badillo Garcia     | `Arquitectura y lógica de integración` |
| Stefany Ausencio Lopez        | `Diseño de interfaces y maquetado` |

---

## 📌 Próximos pasos (en desarrollo)

 * Implementacion del backend.

 * Implementacion del maquetado

---

# 📄 Licencia

Este proyecto es parte de un proceso académico (estadías) y no está destinado para uso comercial sin autorización expresa del equipo.

---