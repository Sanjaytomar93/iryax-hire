import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../model/job_model.dart';
import 'job_company_logo.dart';
import 'job_tag.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;
  final VoidCallback onSaveTap;

  const JobCardWidget({
    super.key,
    required this.job,
    required this.onSaveTap,
  });

  String _postedAgo(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return '3 Days ago';
    }

    final difference =
    DateTime.now().difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} Days ago';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours} Hours ago';
    }

    return 'Today';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(
          AppRoutes.jobDetails,
          arguments: job.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.fromLTRB(
          18,
          16,
          16,
          15,
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2D2D3A),
            width: 1,
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

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.companyName.isEmpty
                            ? 'Company'
                            : job.companyName,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12.5,
                          fontWeight:
                          FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        job.role.isEmpty
                            ? 'Job Role'
                            : job.role,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${job.location.isEmpty ? 'India' : job.location}'
                            '   •   '
                            '${job.jobType.isEmpty ? 'Onsite' : job.jobType}',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: onSaveTap,
                  child: Icon(
                    job.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: AppColors.white,
                    size: 23,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            Row(
              children: [
                Expanded(
                  child: JobTag(
                    text: job.jobType == 'short'
                        ? 'Short Job'
                        : 'Remote',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: JobTag(
                    text:
                    job.totalDuration.isNotEmpty
                        ? job.totalDuration
                        : job.jobType.isEmpty
                        ? 'Full Time'
                        : job.jobType,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: JobTag(
                    text: job.experience.isEmpty
                        ? 'Fresher'
                        : '${job.experience} Yrs',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            Row(
              children: [
                Text(
                  _postedAgo(job.createdAt),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}