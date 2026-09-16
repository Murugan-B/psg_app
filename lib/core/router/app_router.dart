import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/features/auth/presentation/landing_screen.dart';
import 'package:psg_app/features/auth/presentation/login_screen.dart';
import 'package:psg_app/features/auth/presentation/role_selection_screen.dart';
import 'package:psg_app/features/auth/presentation/register_screen.dart';
import 'package:psg_app/features/assessments/presentation/assessment_list_screen.dart';
import 'package:psg_app/features/assessments/presentation/take_assessment_screen.dart';
import 'package:psg_app/features/assessments/presentation/assessment_results_screen.dart';
import 'package:psg_app/features/resources/presentation/resource_list_screen.dart';
import 'package:psg_app/features/resources/presentation/resource_detail_screen.dart';
import 'package:psg_app/features/recommendations/presentation/recommendations_screen.dart';
import 'package:psg_app/features/competency/presentation/competency_dashboard_screen.dart';

import 'package:psg_app/screens/student_main_screen.dart';
import 'package:psg_app/screens/faculty_main_screen.dart';
import 'package:psg_app/screens/admin_main_screen.dart';
import 'package:psg_app/screens/faculty_generate_otp_screen.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  refreshListenable: _AuthRefreshNotifier(),
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;

    final isAuthRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/role_selection' ||
        state.matchedLocation == '/register';

    if (session == null) {
      // If not logged in, they can only access auth routes
      return isAuthRoute ? null : '/';
    }

    // If logged in, let them access anything.
    // Wait, if they hit an auth route while logged in, they should go to a "resolver" route.
    // The LandingScreen ('/') will act as our resolver if they are logged in!
    if (isAuthRoute && state.matchedLocation != '/') {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/role_selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final role = state.extra as String? ?? 'student';
        return LoginScreen(role: role);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final role = state.extra as String? ?? 'student';
        return RegisterScreen(role: role);
      },
    ),
    GoRoute(
      path: '/student_main',
      builder: (context, state) => const StudentMainScreen(),
    ),
    GoRoute(
      path: '/faculty_main',
      builder: (context, state) => const FacultyMainScreen(),
    ),
    GoRoute(
      path: '/admin_main',
      builder: (context, state) => const AdminMainScreen(),
    ),
     GoRoute(
       path: '/staff/attendance/create',
       builder: (context, state) => const FacultyGenerateOtpScreen(),
     ),
     GoRoute(
       path: '/assessments',
       builder: (context, state) => const AssessmentListScreen(),
     ),
     GoRoute(
       path: '/assessments/:id/take',
       builder: (context, state) => TakeAssessmentScreen(assessmentId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/assessments/:id/results',
       builder: (context, state) => AssessmentResultsScreen(assessmentId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/resources',
       builder: (context, state) => const ResourceListScreen(),
     ),
     GoRoute(
       path: '/resources/:id',
       builder: (context, state) => ResourceDetailScreen(resourceId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/recommendations',
       builder: (context, state) => const RecommendationsScreen(),
     ),
     GoRoute(
       path: '/competencies',
       builder: (context, state) => const CompetencyDashboardScreen(),
     ),
  ],
);
