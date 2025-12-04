import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import 'package:myapp/widgets/auth_widgets.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Error al registrar',
        name: 'Registration',
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Ocurrió un error inesperado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                vertical: 140.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Encabezado
                  AuthHeader(
                    title: 'CREAR CUENTA',
                    subtitle: 'AgendaFio',
                    description: 'Únete para gestionar tus gastos',
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
                          isLeftActive: false,
                          onLeftTap: () => context.go('/login'),
                          onRightTap: () {},
                        ),
                        const SizedBox(height: 24),
                        // Campo de email
                        EmailTextField(controller: _emailController),
                        const SizedBox(height: 16),
                        // Campo de contraseña
                        PasswordTextField(controller: _passwordController),
                        const SizedBox(height: 24),
                        // Botón de acción
                        ActionButton(
                          label: 'Crear cuenta',
                          onPressed: _register,
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
