import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../../home/controller/home_controller.dart';
import '../../home/widgets/job_card_widget.dart';
import '../controller/short_jobs_controller.dart';

class ShortJobsView extends GetView<ShortJobsController> {
  const ShortJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: const MainBottomNav(
        currentIndex: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  );
                }

                if (controller.error.value.isNotEmpty &&
                    controller.shortJobs.isEmpty) {
                  return _errorView();
                }

                if (controller.shortJobs.isEmpty) {
                  return _emptyView();
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshShortJobs,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      20,
                      22,
                      120,
                    ),
                    itemCount: controller.shortJobs.length,
                    itemBuilder: (_, index) {
                      final job = controller.shortJobs[index];

                      return JobCardWidget(
                        job: job,
                        onSaveTap: () {
                          if (Get.isRegistered<HomeController>()) {
                            Get.find<HomeController>().toggleSave(job);
                          } else {
                            controller.toggleSave(job);
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF211F20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Text(
              'Short Jobs',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.greyText,
              size: 52,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load short jobs',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: controller.getShortJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Text(
        'No short jobs available',
        style: TextStyle(
          color: AppColors.greyText,
          fontSize: 16,
        ),
      ),
    );
  }
}