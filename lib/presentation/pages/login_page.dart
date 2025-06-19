import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/user_provider.dart';
import '../../domain/entities/user.dart';
import '../router/app_routes.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLogin ? 'Iniciar sesión' : 'Registrarse',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 24.0),
              child: Text(
                'Comencemos rellenando el formulario que aparece a continuación.',
                style: GoogleFonts.plusJakartaSans(),
              ),
            ),
            if (!isLogin)
              CustomInput(
                controller: nameController,
                isPassword: false,
                hintText: 'Nombre',
              ),
            if (!isLogin) const SizedBox(height: 8),

            CustomInput(
              controller: emailController,
              isPassword: false,
              hintText: 'Correo electrónico',
            ),
            const SizedBox(height: 8),
            CustomInput(
              controller: passwordController,
              isPassword: true,
              hintText: 'Contraseña',
            ),

            const SizedBox(height: 20),
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                child: CustomButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    bool success = false;
                    User? user;

                    if (isLogin) {
                      success = await authProvider.login(email, password);
                    } else {
                      final name = nameController.text.trim();
                      success = await authProvider.register(
                        name,
                        email,
                        password,
                      );
                    }

                    // Intentamos obtener el usuario actual
                    user = authProvider.user;

                    if (success && user != null) {
                      userProvider.setUser(user);
                      context.go(AppRoutes.home);
                    }
                  },
                  text: isLogin ? 'Iniciar sesión' : 'Registrarse',
                  options: ButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppColors.primary,
                    textStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.info,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 3.0,
                    borderRadius: 12,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin
                    ? '¿No tienes cuenta? Regístrate'
                    : '¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  authProvider.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
