import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class JobTag extends StatelessWidget {
  final String text;

  const JobTag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF34343D),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.greyText,
          fontSize: 10.5,
        ),
      ),
    );
  }
}