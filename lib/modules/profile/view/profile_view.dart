import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_avatar_widget.dart';
import '../widgets/profile_completion_bar.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_top_header.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: const MainBottomNav(currentIndex: 4),
      body: Stack(
        children: [
          const ProfileTopHeader(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(27, 84, 27, 120),
              child: Column(
                children: [
                  ProfileAvatarWidget(
                    imageUrl: '',
                    onEdit: () {},
                  ),

                  const SizedBox(height: 18),

                  Obx(() {
                    if (controller.isLoading.value && controller.profile.value == null) {
                      return const ProfileCompletionBar(value: 0.0);
                    }

                    return ProfileCompletionBar(
                      value: controller.profileCompletion,
                    );
                  }),

                  // const ProfileCompletionBar(value: 0.30),

                  const SizedBox(height: 30),

                  ProfileMenuTile(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Get.toNamed(AppRoutes.personalDetails);
                    },
                  ),

                  ProfileMenuTile(
                    icon: Icons.file_copy_rounded,
                    title: 'Personal Documents',
                    onTap: () {
                      Get.toNamed(AppRoutes.personalDocuments);
                    },
                  ),


                  ProfileMenuTile(
                    icon: Icons.medical_information_rounded,
                    title: 'Medical Certificate',
                    onTap: () async {
                      if (controller.candidateId.value.isEmpty) {
                        await controller.getProfile();
                      }

                      Get.toNamed(AppRoutes.medicalCertificate);
                    },
                  ),

                  // ProfileMenuTile(
                  //   icon: Icons.medical_information_rounded,
                  //   title: 'Medical Certificate',
                  //   onTap: () {
                  //     Get.toNamed(AppRoutes.medicalCertificate);
                  //   },
                  // ),

                  ProfileMenuTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet',
                    onTap: () {
                      Get.toNamed(AppRoutes.wallet);
                    },
                  ),


                   ProfileMenuTile(
                    icon: Icons.email_sharp,
                    title: 'Offer Letters',
                    onTap: () {
                      Get.toNamed(AppRoutes.offerLetters);
                    },
                  ),



                  const SizedBox(height: 32),

                  ProfileLogoutButton(
                    onTap: () async {
                      await StorageService.clear();
                      Get.offAllNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}