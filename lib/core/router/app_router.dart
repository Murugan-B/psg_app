import 'package:go_router/go_router.dart';
import 'package:vishnu_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:vishnu_mobile/features/auth/presentation/screens/login_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(
        onFinish: () {
          context.go('/login');
        },
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
