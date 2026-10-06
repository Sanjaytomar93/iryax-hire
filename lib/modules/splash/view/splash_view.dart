import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/logo_widget.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LogoWidget(
                vertical: true,
                size: 74,
                textSize: 27,
              ),
              SizedBox(height: 22),
              Text(
                'one login one dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}