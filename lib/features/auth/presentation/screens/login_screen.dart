import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vishnu_mobile/core/theme/app_colors.dart';
import 'package:vishnu_mobile/core/theme/app_text_styles.dart';
import 'package:vishnu_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:vishnu_mobile/shared/widgets/cards/custom_card.dart';
import 'package:vishnu_mobile/shared/widgets/inputs/custom_text_field.dart';
import 'package:vishnu_mobile/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password.')),
      );
      return;
    }

    ref.read(authProvider.notifier).login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;

    ref.listen<AsyncValue<void>>(authProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString().replaceAll('Exception: ', ''))),
        );
      } else if (next is AsyncData && previous is AsyncLoading) {
        // Since we are mocking login and there is no authenticated screen yet,
        // we show a success message.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login success!')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            
            // Main Scrollable Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCard(
                      width: MediaQuery.of(context).size.width * 0.88,
                      maxWidth: 360,
                      padding: const EdgeInsets.only(
                        left: 28,
                        right: 28,
                        top: 36,
                        bottom: 24,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo Container
                              Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Vishnu',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.warning,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),

                              // Title and Subtitle
                              Text(
                                'Vishnu Mobile Shop',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Inventory Management System',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Username Input
                              CustomTextField(
                                label: 'USERNAME',
                                placeholder: 'Enter your username',
                                controller: _usernameController,
                                trailing: SvgPicture.asset(
                                  'assets/icons/person.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.text.withValues(alpha: 0.6),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),

                              // Password Input
                              CustomTextField(
                                label: 'PASSWORD',
                                placeholder: '••••••••',
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                trailing: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/eye.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.text.withValues(alpha: 0.6),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 2),

                              // Login Button
                              PrimaryButton(
                                text: 'Login  →',
                                isLoading: isLoading,
                                onPressed: _handleLogin,
                              ),
                              const SizedBox(height: 18),

                              // Forgot Password
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please contact your administrator.')),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      'Forgot password?',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Divider
                              Container(
                                height: 1,
                                color: AppColors.border,
                                margin: const EdgeInsets.symmetric(vertical: 20),
                              ),

                              // Register Link
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    // Normally opens register modal
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Joining as staff?',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.muted,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Register here',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Watermark
                          Positioned(
                            bottom: -10, // Adjust slightly to match absolute positioning inside card
                            right: -12,  // Relative to card padding
                            child: IgnorePointer(
                              child: Text(
                                'VMS',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary.withValues(alpha: 0.07),
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            '© ${DateTime.now().year} Vishnu Mobile Shop Inventory Management System',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Privacy Policy',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                              Text(
                                ' · ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFFAAAAAA),
                                ),
                              ),
                              Text(
                                'Terms of Service',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                              Text(
                                ' · ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFFAAAAAA),
                                ),
                              ),
                              Text(
                                'Support',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
