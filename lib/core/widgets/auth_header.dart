import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'logo_widget.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.31,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.header,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -120,
            top: -190,
            child: Container(
              height: 500,
              width: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.headerCircle.withOpacity(.55),
              ),
            ),
          ),

          Positioned(
            left: -90,
            top: -125,
            child: Container(
              height: 250,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.04),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),

                const Center(
                  child: LogoWidget(
                    size: 48,
                    textSize: 22,
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}