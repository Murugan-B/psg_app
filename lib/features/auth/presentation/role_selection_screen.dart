import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.school, size: 48, color: Color(0xFF2E63EB)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the role that best describes you',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),
              _buildRoleCard(
                context,
                title: 'Student',
                subtitle: 'View attendance, timetable, and mark attendance',
                icon: Icons.school,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFD1FAE5),
                onTap: () => context.go('/login', extra: 'student'),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: 'Faculty',
                subtitle: 'Generate OTP, manage classes, and view timetable',
                icon: Icons.person,
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => context.go('/login', extra: 'faculty'),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: 'Admin',
                subtitle: 'Manage students, faculty, classes, and timetable',
                icon: Icons.admin_panel_settings,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFEDE9FE),
                onTap: () => context.go('/login', extra: 'admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 24),
          ],
        ),
      ),
    );
  }
}
