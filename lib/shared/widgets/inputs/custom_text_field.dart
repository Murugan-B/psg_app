import 'package:flutter/material.dart';
import 'package:vishnu_mobile/core/theme/app_colors.dart';
import 'package:vishnu_mobile/core/theme/app_text_styles.dart';
import 'package:vishnu_mobile/core/theme/app_radius.dart';
import 'package:vishnu_mobile/core/theme/app_spacing.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? icon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.micro.copyWith(
            fontWeight: AppTextStyles.bold,
            color: AppColors.muted, // Mapped to #555 equivalent
          ),
        ),
        const SizedBox(height: AppSpacing.p6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.background, // Mapped to #F2F2F7 equivalent
            borderRadius: BorderRadius.circular(AppRadius.r10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15, // Exact match to RN
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.p8),
                Icon(
                  icon,
                  size: 16,
                  color: AppColors.text.withOpacity(0.5),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.p16),
      ],
    );
  }
}
