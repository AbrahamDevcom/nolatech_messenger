# Nolatech Messenger

Una aplicación de mensajería construida con Flutter y Firebase, diseñada con principios de Clean Architecture, pruebas unitarias, y optimizaciones de rendimiento.

---

## ✨ Características principales

- Autenticación con Firebase Auth
- Mensajería en tiempo real usando Firebase Realtime Database
- Gestor de estado con Provider y GetIt
- Arquitectura limpia: Domain / Data / Presentation
- Enrutamiento con GoRouter
- Lazy loading de mensajes, debounce en inputs, control de sesiones
- Tests unitarios para casos de uso clave

---

## 📦 Instrucciones de instalación y ejecución

### Requisitos previos

- Flutter >= 3.13
- Firebase configurado (Web/Android/iOS)

### 1. Clonar el repositorio

```bash
https://github.com/abrahamdevcom/nolatech_messenger.git
cd nolatech_messenger
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

Agrega tu archivo `google-services.json` en `android/app` y/o `GoogleService-Info.plist` para iOS.

### 4. Ejecutar build\_runner (para generar mocks y modelos si usas freezed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Ejecutar la app

```bash
flutter run
```

### 6. Ejecutar tests

```bash
flutter test
```

---

## 🔎 Diagrama de arquitectura

```plaintext
lib/
├── core/
│   └── errors/
│   └── usecases/
│   └── utils/
├── data/
│   └── repositories/
│   └── models/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── providers/
│   └── router/
│   └── utils/
│   └── widgets/
├── di/
│   └── service_locator.dart
└── main.dart

test/
├── domain/
│   └── usecases/
├── helpers/
```

### Flujo de datos:

```
UI <--> Provider <--> UseCases <--> Repository (abstracción) <--> Firebase (implementación)
```

Se utiliza **GetIt** para inyección de dependencias, **Provider** para la gestión reactiva de estado, y **GoRouter** para manejo declarativo de rutas.

---

## 🚀 Reporte de optimización (rendimiento)

### 🔄 Lazy loading de mensajes

- Los mensajes se cargan de forma paginada con scroll listener
- Ahorra memoria y mejora el rendimiento en chats largos

### ⏳ Debounce en el campo de texto

- Reduce llamadas innecesarias al escribir mensajes o al buscar contactos
- Mejora fluidez y economía de red

### ✅ StreamBuilder eficiente

- Uso controlado de `notifyListeners()` en providers
- Los `Stream`s están organizados para minimizar reconstrucciones innecesarias

### 🌀 Gestión de sesión y persistencia

- Firebase mantiene sesión iniciada
- `checkAuthStatus()` asegura que se restaure el estado al abrir la app
- El `UserProvider` mantiene información global del usuario

### ⚖️ Tests unitarios

- Casos de uso como `LoginUser`, `RegisterUser`, `SendMessage` están testeados
- Uso de `mockito` para testear interacciones sin acceder a Firebase

---

## 🚧 Pendientes y mejoras futuras

- Integracion de llamadas
- Chat grupal y mensajes multimedia
- Soporte para reacciones y edición de mensajes
- Notificaciones push con Firebase Cloud Messaging
- Tema oscuro y personalización

---

## 📖 Licencia

[MIT](LICENSE)

---

**Hecho con Flutter ❤ y Firebase por el futuro equipo de Nolatech.**

