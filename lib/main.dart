import 'package:flutter/material.dart';
import 'di/service_locator.dart' as di;
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/providers.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/router/app_router.dart';

final sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init(); // tu función de inyección con GetIt

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtén instancia de AuthProvider desde GetIt
    final authProvider = sl<AuthProvider>();

    final router = AppRouter(authProvider).router;
    // Llama checkAuthStatus para cargar sesión antes de mostrar UI
    authProvider.checkAuthStatus();

    return MultiProvider(
      providers: appProviders,
      child: MaterialApp.router(
        title: 'Nolatech Messenger',
        routerConfig: router,
      ),
    );
  }
}

/*
📁 lib/
│
├── core/
│   ├── errors/
│   │   └── failure.dart
│   ├── usecases/
│   │   └── usecase.dart
│   └── utils/
│       └── constants.dart
│
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── chat_remote_datasource.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── message_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── chat_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── message.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── chat_repository.dart
│   └── usecases/
│       ├── login_user.dart
│       └── send_message.dart
│
├── presentation/
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── chat_list_page.dart
│   │   └── chat_page.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── chat_provider.dart
│   └── widgets/
│       ├── message_bubble.dart
│       └── chat_input.dart
│
├── di/
│   └── service_locator.dart
│
└── main.dart
*/
