import 'package:flutter/material.dart';
import 'package:vishnu_mobile/core/theme/app_colors.dart';
import 'package:vishnu_mobile/core/theme/app_text_styles.dart';
import 'package:vishnu_mobile/core/theme/app_spacing.dart';
import 'package:vishnu_mobile/core/theme/app_dimensions.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _spinController;
  late AnimationController _floatController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _translateAnim;
  late Animation<double> _dotsFadeAnim;
  
  late Animation<double> _ring1Anim;
  late Animation<double> _ring2Anim;
  late Animation<double> _spinAnim;

  @override
  void initState() {
    super.initState();

    // Fade Controller
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    // Pulse Controller (1.5s in RN)
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _ring1Anim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.97, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.03, end: 0.97), weight: 50),
    ]).animate(_pulseController);

    // Ring 2 logic (delayed by 600ms in RN)
    _ring2Anim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.97, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.03, end: 0.97), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: const Interval(0.4, 1.0, curve: Curves.linear),
    ));

    _pulseController.repeat();

    // Spin Controller (2s in RN)
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _spinAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_spinController);
    _spinController.repeat();

    // Float Controller (Spring in RN, mapped to curve in Flutter)
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _floatController, curve: Curves.elasticOut));
    _translateAnim = Tween<double>(begin: 30.0, end: 0.0).animate(CurvedAnimation(parent: _floatController, curve: Curves.elasticOut));

    // Dots Controller
    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _dotsFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_dotsController);
    
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    _floatController.forward();
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _dotsController.forward();

    // Wait 2.5 seconds total
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Exit transition
    if (mounted) {
      widget.onFinish();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _spinController.dispose();
    _floatController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark, // #1a1c6b
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeController, _pulseController, _spinController, _floatController, _dotsController]),
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnim.value, // Maps to exitAnim during transition out
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rings
                  Transform.scale(
                    scale: _ring1Anim.value,
                    child: Container(
                      width: AppDimensions.splashRing1,
                      height: AppDimensions.splashRing1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _ring2Anim.value, // Rough approximation of the delayed pulse
                    child: Container(
                      width: AppDimensions.splashRing2,
                      height: AppDimensions.splashRing2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
                      ),
                    ),
                  ),
                  
                  // Main Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.translate(
                          offset: Offset(0, _translateAnim.value),
                          child: Transform.scale(
                            scale: _scaleAnim.value,
                            child: Column(
                              children: [
                                // Logo Outer Ring
                                RotationTransition(
                                  turns: _spinAnim,
                                  child: Container(
                                    width: AppDimensions.splashOuterLogo,
                                    height: AppDimensions.splashOuterLogo,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 2),
                                      // Top border simulation using gradient/border tricks is complex, using standard border for now
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: AppDimensions.splashInnerLogo,
                                      height: AppDimensions.splashInnerLogo,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset('assets/logo.png', width: AppDimensions.splashLogoImage, height: AppDimensions.splashLogoImage, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, color: Colors.white, size: 30)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.p20),
                                Text(
                                  'Vishnu Mobile',
                                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.p6),
                                Text(
                                  'SHOP MANAGEMENT',
                                  style: AppTextStyles.micro.copyWith(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.p40),
                      
                      // Bouncing Dots (Simplified for now)
                      Opacity(
                        opacity: _dotsFadeAnim.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(0),
                            const SizedBox(width: AppSpacing.p8),
                            _buildDot(150),
                            const SizedBox(width: AppSpacing.p8),
                            _buildDot(300),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(int delay) {
    // A simplified placeholder for the bouncing dot logic.
    // In strict RN 1:1, we'd need a separate StatefulWidget for each dot.
    return Container(
      width: AppDimensions.splashDotSize,
      height: AppDimensions.splashDotSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
    );
  }
}
