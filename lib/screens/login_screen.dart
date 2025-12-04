import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import 'package:myapp/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Error al iniciar sesión',
        name: 'Login',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Ocurrió un error inesperado.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 110.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Encabezado
                  AuthHeader(
                    title: 'BIENVENIDO',
                    subtitle: 'AgendaFio',
                    description: 'Iniciar sesión para continuar',
                  ),
                  const SizedBox(height: 50),
                  // Tarjeta del formulario
                  AuthFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tabs de navegación
                        AuthTabBar(
                          leftTabLabel: 'Iniciar sesión',
                          rightTabLabel: 'Crear cuenta',
                          isLeftActive: true,
                          onLeftTap: () {},
                          onRightTap: () => context.go('/signup'),
                        ),
                        const SizedBox(height: 24),
                        // Campo de email
                        EmailTextField(controller: _emailController),
                        const SizedBox(height: 16),
                        // Campo de contraseña
                        PasswordTextField(controller: _passwordController),
                        const SizedBox(height: 12),
                        // Botón de recuperar contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.go('/forgot-password');
                            },
                            child: Text(
                              'Recuperar contraseña-en desarrollo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Botón de acción
                        ActionButton(
                          label: 'Iniciar sesión',
                          onPressed: _login,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
