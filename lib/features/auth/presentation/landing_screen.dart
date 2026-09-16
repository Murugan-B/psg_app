import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        final res = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .single();
        final role = res['role'] as String? ?? 'student';
        
        if (mounted) {
          if (role == 'admin') {
            context.go('/admin_main');
          } else if (role == 'faculty') {
            context.go('/faculty_main');
          } else {
            context.go('/student_main');
          }
        }
        return; // Success, do not stop loading spinner
      } catch (e) {
        // Fall back to landing screen on error
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E63EB)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F347F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Edu',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F347F),
                              ),
                            ),
                            TextSpan(
                              text: 'Track',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E63EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ATTEND TODAY   ACHIEVE TOMORROW',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Welcome Text
                const Text(
                  'Welcome to EduTrack',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your comprehensive platform for academic attendance,\nskill development, and competency tracking.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/role_selection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E63EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: const Color(0xFFE2E8F0)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: const Color(0xFFE2E8F0)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => _signInWithGoogle(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://raw.githubusercontent.com/devicons/go/master/svg/godoc-template.svg',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata,
                                  size: 24, color: Color(0xFF2E63EB)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) {
    // Auth will be handled via provider in production
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in coming soon')),
    );
  }
}
