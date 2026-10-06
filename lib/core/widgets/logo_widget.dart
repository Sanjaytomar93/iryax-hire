import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final double textSize;
  final bool vertical;

  const LogoWidget({
    super.key,
    this.size = 50,
    this.textSize = 22,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'IG',
        style: TextStyle(
          color: AppColors.black,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );

    final title = Text(
      'INGRAIN SYSTEM',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.white,
        fontSize: textSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.7,
        height: 1.1,
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(height: 12),
          title,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        logo,
        const SizedBox(width: 14),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: title,
          ),
        ),
      ],
    );
  }
}