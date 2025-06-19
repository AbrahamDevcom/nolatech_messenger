import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nolatech_messenger/domain/usecases/register_user.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/get_user.dart';
import '../domain/usecases/login_user.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/send_message.dart';
import '../presentation/providers/auth_provider.dart' as auth;
import 'package:firebase_database/firebase_database.dart';

import '../presentation/providers/chat_provider.dart';
import '../presentation/providers/user_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton<DatabaseReference>(
    () => FirebaseDatabase.instance.ref(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<FirebaseAuth>(), sl<DatabaseReference>()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl());

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetUserData(sl()));
  sl.registerLazySingleton(() => SendUserMessage(sl()));

  // Providers
  sl.registerLazySingleton<auth.AuthProvider>(
    () => auth.AuthProvider(
      sl<LoginUser>(),
      sl<RegisterUser>(),
      sl<LogoutUser>(),
      sl<GetUserData>(),
      sl<FirebaseAuth>(),
      sl<UserProvider>(),
    ),
  );
  // UserProvider is a custom provider that manages user state
  sl.registerLazySingleton(() => UserProvider());
  sl.registerLazySingleton(
    () => ChatProvider(
      sl<ChatRepository>(),
      sl<UserProvider>(),
      sl<SendUserMessage>(),
    ),
  );
}
