import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vishnu_mobile/core/theme/app_colors.dart';
import 'package:vishnu_mobile/core/theme/app_text_styles.dart';
import 'package:vishnu_mobile/features/auth/presentation/providers/auth_provider.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  offset: const Offset(0, 4), // elevation 6 approx
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⏳',
                  style: TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 16),
                Text(
                  'Approval Pending',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your account is waiting for admin confirmation.\n'
                  'Please wait — the admin will approve your account shortly.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.muted,
                    height: 1.57, // 22 / 14 approx
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  child: Text(
                    '← Back to Login',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
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
}
