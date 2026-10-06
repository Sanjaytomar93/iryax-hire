import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../controller/home_controller.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/job_card_widget.dart';
import '../widgets/overview_card.dart';
import '../widgets/sticky_search_delegate.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,

      // Fixed Header
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.black,
        surfaceTintColor: AppColors.black,
        elevation: 0,
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Obx(() {
          final dashboard = controller.dashboard.value;

          final displayName =
          dashboard?.name.trim().isNotEmpty == true
              ? dashboard!.name
              : controller.candidateName;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
            ),
            child: HomeHeaderWidget(
              name: _firstName(displayName),
            ),
          );
        }),
      ),

      bottomNavigationBar: const MainBottomNav(
        currentIndex: 0,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          );
        }

        final dashboard = controller.dashboard.value;
        final jobs = controller.filteredJobs;

        return RefreshIndicator(
          onRefresh: controller.loadHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Overview section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const Spacer(),

                          GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.applications,
                              );
                            },
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF1E9BFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          OverviewCard(
                            title: 'Applied Jobs',
                            count: dashboard?.applied ?? 0,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.applications,
                              );
                            },
                          ),

                          const SizedBox(width: 14),

                          OverviewCard(
                            title: 'Shortlisted',
                            count: dashboard?.active ?? 0,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.applications,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          OverviewCard(
                            title: 'Interviewed',
                            count:
                            dashboard?.interviews ?? 0,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.applications,
                                arguments: {
                                  'tab': 0,
                                  'filter': 'Interview',
                                },
                              );
                            },
                          ),

                          const SizedBox(width: 14),

                          OverviewCard(
                            title: 'Open Roles',
                            count:
                            dashboard?.openRoles ?? 0,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.explore,
                              );
                              // controller.clearSearch();
                              // controller.clearFilters();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Sticky search
              SliverPersistentHeader(
                pinned: true,
                delegate: StickySearchDelegate(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: HomeSearchBar(
                      controller:
                      controller.searchController,
                      onChanged:
                      controller.onSearchChanged,
                      selectedFilter:
                      controller.selectedJobType.value,
                      onFilterSelected:
                      controller.onFilterSelected,
                    ),
                  ),
                ),
              ),

              // Empty State
              if (jobs.isEmpty)
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

              // Job list
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    14,
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
    );
  }

  String _firstName(String name) {
    if (name.trim().isEmpty) {
      return 'Candidate';
    }

    return name.trim().split(' ').first;
  }
}