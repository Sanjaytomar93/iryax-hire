import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../../home/model/job_model.dart';
import '../../home/widgets/job_company_logo.dart';
import '../../home/widgets/job_tag.dart';
import '../controller/applications_controller.dart';
import '../model/application_model.dart';

class ApplicationsView extends GetView<ApplicationsController> {
  const ApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              8,
            ),
            child: _topBar(),
          ),
        ),
      ),

      bottomNavigationBar: const MainBottomNav(
        currentIndex: 3,
      ),

      body: Obx(
            () => RefreshIndicator(
          onRefresh: controller.loadApplications,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _mainTabs(),

                      if (controller.selectedTab.value == 0) ...[
                        const SizedBox(height: 18),
                        _filters(),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              if (controller.isLoading.value)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                )
              else if (controller.selectedTab.value == 0)
                _appliedSliver()
              else
                _savedSliver(),

              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Text(
            'Applications',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF211F20),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              Positioned(
                right: 8,
                top: 7,
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mainTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton(
            index: 0,
            title:
            'Applied Jobs(${controller.applications.length})',
          ),
          _tabButton(
            index: 1,
            title:
            'Saved Jobs(${controller.savedJobs.length})',
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String title,
  }) {
    final selected =
        controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedTab.value = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? AppColors.black
                  : AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    const filters = [
      'All',
      'Submitted',
      'Interview',
      'Accepted',
      'Rejected',
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = filters[index];

          final selected =
              controller.selectedFilter.value == item;

          return GestureDetector(
            onTap: () {
              controller.selectedFilter.value = item;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.white
                    : AppColors.field,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? AppColors.white
                      : const Color(0xFF3A3A4A),
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: selected
                      ? AppColors.black
                      : AppColors.lightGrey,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _appliedSliver() {
    final list = controller.filteredApplications;

    if (list.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyText(
          text: 'No applied jobs found',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return _AppliedApplicationCard(
              application: list[index],
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _savedSliver() {
    final list = controller.savedJobs;

    if (list.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyText(
          text: 'No saved jobs found',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final job = list[index];

            return _SavedJobCard(
              job: job,
              onBookmarkTap: () {
                controller.toggleSavedJob(job);
              },
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }
}

class _AppliedApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _AppliedApplicationCard({
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final job = application.job;
    final interview = application.interview;

    final bool showInterviewDetails =
        application.hasInterview &&
            interview.hasSchedule;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (application.id.trim().isEmpty) {
          Get.snackbar(
            'Application',
            'Application ID is missing',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF252525),
            colorText: AppColors.white,
          );
          return;
        }

        Get.toNamed(
          AppRoutes.applicationDetails,
          arguments: {
            'applicationId': application.id,
            'application': application,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          14,
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF30303A),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JobCompanyLogo(
                  companyName: job.companyName,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _JobTitleBlock(
                    job: job,
                  ),
                ),

                if (showInterviewDetails)
                  _InterviewModeBadge(
                    online: interview.isOnline,
                  ),
              ],
            ),

            const SizedBox(height: 13),

            Divider(
              height: 1,
              color: AppColors.white.withOpacity(.22),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.radio_button_checked,
                  color: _statusColor(application),
                  size: 14,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    application.cardStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Text(
                  'View Details',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 4),

                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.white,
                  size: 14,
                ),
              ],
            ),

            if (showInterviewDetails) ...[
              const SizedBox(height: 11),

              if (interview.scheduledAt != null)
                _InterviewInformationText(
                  label: 'Date & Time',
                  value: DateFormat(
                    'dd/MM/yyyy hh:mm a',
                  ).format(
                    interview.scheduledAt!.toLocal(),
                  ),
                ),

              if (interview.address.trim().isNotEmpty) ...[
                if (interview.scheduledAt != null)
                  const SizedBox(height: 6),

                _InterviewInformationText(
                  label: 'Place',
                  value: interview.address.trim(),
                ),
              ] else if (interview.link.trim().isNotEmpty) ...[
                if (interview.scheduledAt != null)
                  const SizedBox(height: 6),

                _InterviewInformationText(
                  label: 'Link',
                  value: interview.link.trim(),
                ),
              ],

              if (interview.isConfirmed ||
                  interview.isDeclined) ...[
                const SizedBox(height: 8),

                Text(
                  interview.isConfirmed
                      ? 'Interview Confirmed'
                      : 'Reschedule Requested',
                  style: TextStyle(
                    color: interview.isConfirmed
                        ? const Color(0xFF49BA59)
                        : const Color(0xFFFFA726),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(ApplicationModel application) {
    final status = application.cardStatus.toLowerCase();

    if (status.contains('confirmed') ||
        status == 'selected' ||
        status.contains('offer')) {
      return const Color(0xFF49BA59);
    }

    if (status.contains('interview')) {
      return const Color(0xFFBDBDBD);
    }

    if (status.contains('rejected') ||
        status.contains('declined')) {
      return const Color(0xFFE05252);
    }

    return AppColors.greyText;
  }
}
class _InterviewModeBadge extends StatelessWidget {
  final bool online;

  const _InterviewModeBadge({
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF062C14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        online ? 'Online' : 'Offline',
        style: const TextStyle(
          color: Color(0xFF42B75A),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InterviewInformationText extends StatelessWidget {
  final String label;
  final String value;

  const _InterviewInformationText({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label : $value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.greyText,
        fontSize: 10.5,
        height: 1.25,
      ),
    );
  }
}

class _SavedJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onBookmarkTap;

  const _SavedJobCard({
    required this.job,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (job.id.isNotEmpty) {
          Get.toNamed(
            AppRoutes.jobDetails,
            arguments: job.id,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(
          16,
          15,
          16,
          14,
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF30303A),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                JobCompanyLogo(
                  companyName: job.companyName,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _JobTitleBlock(
                    job: job,
                  ),
                ),

                GestureDetector(
                  onTap: onBookmarkTap,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4A4A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(
                  child: JobTag(
                    text: 'Remote',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: JobTag(
                    text: job.jobType.isEmpty
                        ? 'Part Time'
                        : job.jobType,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: JobTag(
                    text: job.experience.isEmpty
                        ? 'Junior'
                        : job.level,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Text(
                  job.postedAgo,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 11.5,
                  ),
                ),

                const Spacer(),

                const Text(
                  'View Details',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 6),

                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobTitleBlock extends StatelessWidget {
  final JobModel job;

  const _JobTitleBlock({
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          job.companyName.isEmpty
              ? 'Company'
              : job.companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          job.role.isEmpty
              ? 'Job Role'
              : job.role,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          '${job.location.isEmpty ? 'India' : job.location}'
              '   •   '
              '${job.jobType.isEmpty ? 'Onsite' : job.jobType}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.greyText,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.greyText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}