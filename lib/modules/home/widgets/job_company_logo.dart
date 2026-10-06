import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class JobCompanyLogo extends StatelessWidget {
  final String companyName;

  const JobCompanyLogo({
    super.key,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final name = companyName.toLowerCase();

    Color bg = AppColors.black;
    Color color = AppColors.white;
    String text = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'J';

    if (name.contains('netflix')) {
      text = 'N';
      color = Colors.red;
    } else if (name.contains('adobe')) {
      text = 'Xd';
      bg = const Color(0xFF4B003D);
      color = const Color(0xFFFF4BE8);
    } else if (name.contains('google')) {
      text = 'G';
      color = Colors.blueAccent;
    }

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2D2D3A),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: text == 'Xd' ? 25 : 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}