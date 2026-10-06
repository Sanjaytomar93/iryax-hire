import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ProfileFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const ProfileFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 50,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            cursorColor: AppColors.white,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.field,
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}