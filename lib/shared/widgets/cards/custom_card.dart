import 'package:flutter/material.dart';
import 'package:vishnu_mobile/core/theme/app_colors.dart';
import 'package:vishnu_mobile/core/theme/app_radius.dart';
import 'package:vishnu_mobile/core/theme/app_spacing.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? maxWidth;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.p24,
      right: AppSpacing.p24,
      top: 36.0,
      bottom: AppSpacing.p24,
    ),
    this.width,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.r24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: child,
    );

    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }

    return content;
  }
}
