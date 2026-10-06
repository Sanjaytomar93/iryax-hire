import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../constants/app_colors.dart';

class AuthBottomLinks extends StatelessWidget {
  final bool showGoogle;
  final String accountText;
  final String actionText;
  final VoidCallback? onActionTap;

  const AuthBottomLinks({
    super.key,
    this.showGoogle = true,
    this.accountText = "DON'T HAVE AN ACCOUNT?",
    this.actionText = 'SignUP',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onActionTap ??
                  () => Get.toNamed(
                AppRoutes.registerEmail,
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$accountText ',
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: actionText,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (showGoogle) ...[
          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.greyText.withOpacity(.55),
                  thickness: .7,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.greyText.withOpacity(.55),
                  thickness: .7,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Container(
          //       height: 46,
          //       width: 46,
          //       decoration: const BoxDecoration(
          //         color: AppColors.white,
          //         shape: BoxShape.circle,
          //       ),
          //       alignment: Alignment.center,
          //       child: const Text(
          //         'G',
          //         style: TextStyle(
          //           color: Colors.red,
          //           fontSize: 24,
          //           fontWeight: FontWeight.w700,
          //         ),
          //       ),
          //     ),
          //
          //     const SizedBox(width: 14),
          //
          //     const Text(
          //       'Login with Google',
          //       style: TextStyle(
          //         color: AppColors.greyText,
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ],
    );
  }
}