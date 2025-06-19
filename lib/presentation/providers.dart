import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../di/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';

List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => sl<AuthProvider>()),
  ChangeNotifierProvider<UserProvider>(create: (_) => sl<UserProvider>()),
  ChangeNotifierProvider<ChatProvider>(create: (_) => sl<ChatProvider>()),
  // Agrega otros providers inyectados con GetIt aquí
];
