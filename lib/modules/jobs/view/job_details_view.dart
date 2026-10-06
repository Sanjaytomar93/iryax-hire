import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/widgets/job_company_logo.dart';
import '../controller/job_details_controller.dart';

class JobDetailsView extends GetView<JobDetailsController> {
  const JobDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: AppColors.black,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          ),
        );
      }

      final job = controller.job.value;

      if (job == null) {
        return const Scaffold(
          backgroundColor: AppColors.black,
          body: Center(
            child: Text(
              'Job not found',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.black,

        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(74),
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
              child: _topBar(job),
            ),
          ),
        ),

        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            40,
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

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.companyName.isEmpty
                              ? 'Company'
                              : job.companyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          job.role.isEmpty
                              ? 'Job Role'
                              : job.role,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    width: job.isApplied ? 112 : 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: job.isApplied
                          ? null
                          : () async {
                        final result = await Get.toNamed(
                          AppRoutes.applyJob,
                          arguments: job,
                        );

                        if (result == true) {
                          controller.markAsApplied();
                        } else {
                          await controller.getJobDetails();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: job.isApplied
                            ? const Color(0xFF333333)
                            : AppColors.primary,
                        disabledBackgroundColor:
                        const Color(0xFF333333),
                        disabledForegroundColor:
                        AppColors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            job.isApplied
                                ? Icons.check_circle_outline
                                : Icons.open_in_new,
                            color: AppColors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            job.isApplied
                                ? 'Applied'
                                : 'Apply',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _iconInfo(
                icon: Icons.location_on_outlined,
                value:
                '${job.location.isEmpty ? 'India' : job.location}   •   ${job.jobType.isEmpty ? 'Onsite' : job.jobType}',
              ),

              const SizedBox(height: 12),

              _iconInfo(
                icon: Icons.currency_rupee,
                value: job.salary.isEmpty
                    ? 'Not disclosed'
                    : job.salary,
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _infoColumn(
                      title: 'Experience',
                      value: job.experience.isEmpty
                          ? 'Fresher'
                          : '${job.experience} Years',
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _infoColumn(
                      title: 'Job Type',
                      value: job.jobType.isEmpty
                          ? 'Full Time'
                          : job.jobType,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _infoColumn(
                      title: 'Level',
                      value: job.level.isEmpty
                          ? 'Entry Level'
                          : job.level,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                'Posted ${job.postedAgo}',
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 11.5,
                ),
              ),

              const SizedBox(height: 22),

              _sectionTitle('Job Posted By'),

              const SizedBox(height: 14),

              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.field,
                    child: Text(
                      job.companyName.isNotEmpty
                          ? job.companyName[0].toUpperCase()
                          : 'H',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HR Manager',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Recruitment Team',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _sectionTitle('Must Have Skills'),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skillList.isEmpty
                    ? [
                  const _SkillChip(
                    text: 'Communication',
                  ),
                  const _SkillChip(
                    text: 'Team Work',
                  ),
                ]
                    : job.skillList
                    .map(
                      (skill) => _SkillChip(
                    text: skill,
                  ),
                )
                    .toList(),
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                'Job Description',
              ),

              const SizedBox(height: 10),

              _paragraph(
                job.description.isEmpty
                    ? 'No job description available.'
                    : job.description,
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                'Requirements',
              ),

              const SizedBox(height: 10),

              _bulletList(
                job.skillList.isEmpty
                    ? [
                  'Good communication skills',
                  'Ability to work with team',
                  'Willingness to learn and grow',
                ]
                    : job.skillList
                    .map(
                      (skill) =>
                  'Experience or knowledge in $skill',
                )
                    .toList(),
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                'Responsibilities',
              ),

              const SizedBox(height: 10),

              _bulletList(
                const [
                  'Understand the assigned tasks and complete them on time',
                  'Coordinate with team members and reporting manager',
                  'Maintain quality and follow company guidelines',
                ],
              ),

              const SizedBox(height: 24),

              Divider(
                color: AppColors.white.withOpacity(.22),
              ),

              const SizedBox(height: 18),

              _sectionTitle(
                'About The Company',
              ),

              const SizedBox(height: 14),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.aboutCompany,
                    arguments: job,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JobCompanyLogo(
                      companyName: job.companyName,
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.companyName.isEmpty
                                ? 'Company'
                                : job.companyName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '${job.jobType.isEmpty ? 'Streaming Online' : job.jobType}'
                                '  •  '
                                '${job.department.isEmpty ? '1500 Employees' : job.department}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.greyText,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.greyText,
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _iconInfo(
                icon: Icons.location_on_outlined,
                value: job.location.isEmpty
                    ? 'Office Address'
                    : job.location,
              ),

              const SizedBox(height: 24),

              Divider(
                color: AppColors.white.withOpacity(.22),
              ),

              const SizedBox(height: 18),

              _sectionTitle(
                'Similar Jobs For You',
              ),

              const SizedBox(height: 10),

              const Text(
                'Similar jobs will be shown here once API is available.',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _topBar(dynamic job) {
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
            'Details',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        GestureDetector(
          onTap: controller.toggleSave,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              job.isSaved
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconInfo({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF211F20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.greyText,
            size: 17,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoColumn({
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.greyText,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 48,
      width: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      color: AppColors.white.withOpacity(.35),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: AppColors.lightGrey,
        fontSize: 12,
        height: 1.5,
      ),
    );
  }

  Widget _bulletList(
      List<String> items,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(
            (item) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 7,
            ),
            child: Text(
              '• $item',
              style: const TextStyle(
                color: AppColors.lightGrey,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;

  const _SkillChip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFF34343D),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.greyText,
          fontSize: 11,
        ),
      ),
    );
  }
}