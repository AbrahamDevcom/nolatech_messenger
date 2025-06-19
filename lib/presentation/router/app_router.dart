import 'package:go_router/go_router.dart';

import '../pages/chat_page.dart';
import '../pages/new_chat_page.dart';
import '../pages/splash_page.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (authProvider.isCheckingAuth) return null;

      final loggedIn = authProvider.user != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (!loggedIn && !isLoggingIn) return AppRoutes.login;
      if (loggedIn && (isLoggingIn || isSplash)) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final recipientName = state.extra as String? ?? '';
          return ChatPage(chatId: chatId, recipientName: recipientName);
        },
      ),
      GoRoute(
        path: AppRoutes.newChat,
        builder: (context, state) => const NewChatPage(),
      ),
    ],
  );
}
