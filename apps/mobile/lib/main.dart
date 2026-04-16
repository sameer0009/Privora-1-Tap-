import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/dashboard/chat_screen.dart';
import 'presentation/providers/auth_provider.dart';

import 'presentation/screens/auth/signup_screen.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/security/security_center.dart';

import 'core/network/background_service_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service for persistent connection
  await BackgroundServiceHandler.init();
  
  runApp(const ProviderScope(child: PrivoraApp()));
}

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final protectedRoutes = ['/dashboard', '/profile', '/settings', '/security', '/chat'];
      final isProtected = protectedRoutes.any((route) => state.matchedLocation.startsWith(route));
      
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isSplash = state.matchedLocation == '/';
      
      if (authState.status == AuthStatus.unknown) return null;
      
      if (authState.status == AuthStatus.authenticated) {
        if (isLoggingIn || isSigningUp || isSplash) return '/dashboard';
        return null;
      }

      if (authState.status == AuthStatus.unauthenticated) {
        if (isSplash) return '/login';
        if (isProtected) return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/security', builder: (context, state) => const SecurityCenterScreen()),
      GoRoute(
        path: '/chat/:deviceId/:pubKey',
        builder: (context, state) => ChatScreen(
          deviceId: state.pathParameters['deviceId']!,
          peerPublicKey: state.pathParameters['pubKey']!,
        ),
      ),
    ],
  );
});

class PrivoraApp extends ConsumerWidget {
  const PrivoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    
    return MaterialApp.router(
      title: 'Privora 1-Tap',
      routerConfig: router,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
