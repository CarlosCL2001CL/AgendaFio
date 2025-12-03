import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/calendar_screen.dart';
import 'package:myapp/screens/forgot_password_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/registration_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegistrationScreen();
          },
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const CalendarScreen();
      },
    ),
  ],
);
