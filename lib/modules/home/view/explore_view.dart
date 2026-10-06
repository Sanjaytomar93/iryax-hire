import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../controller/explore_controller.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/job_card_widget.dart';
import '../widgets/sticky_search_delegate.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRoutes.home);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.black,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.black,
          surfaceTintColor: AppColors.black,
          elevation: 0,
          toolbarHeight: 16,
        ),

        bottomNavigationBar: const MainBottomNav(
          currentIndex: 1,
        ),

        body: Obx(() {
          if (controller.isLoading.value &&
              controller.allJobs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            );
          }

          final jobs = controller.filteredJobs;

          return RefreshIndicator(
            onRefresh: controller.getAllJobs,
            child: CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickySearchDelegate(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: HomeSearchBar(
                        controller:
                        controller.searchController,
                        onChanged:
                        controller.onSearchChanged,
                        selectedFilter: controller
                            .selectedJobType.value,
                        onFilterSelected:
                        controller.onFilterSelected,
                      ),
                    ),
                  ),
                ),

                if (controller.error.value.isNotEmpty &&
                    jobs.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 80,
                        left: 22,
                        right: 22,
                      ),
                      child: Column(
                        children: [
                          Text(
                            controller.error.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.greyText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed:
                            controller.getAllJobs,
                            child: const Text(
                              'Try Again',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (jobs.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 80,
                      ),
                      child: Center(
                        child: Text(
                          'No jobs available',
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      22,
                      20,
                      22,
                      120,
                    ),
                    sliver: SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final job = jobs[index];

                          return JobCardWidget(
                            job: job,
                            onSaveTap: () {
                              controller.toggleSave(job);
                            },
                          );
                        },
                        childCount: jobs.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}