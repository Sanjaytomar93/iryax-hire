import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/experience_controller.dart';
import '../model/experience_model.dart';

class ExperienceCardWidget extends GetView<ExperienceController> {
  final ExperienceModel experience;

  const ExperienceCardWidget({
    super.key,
    required this.experience,
  });

  String _year(
      String value,
      ) {
    final text = value.trim();

    if (text.isEmpty) {
      return 'Present';
    }

    if (text.length >= 4) {
      return text.substring(0, 4);
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final yearText =
        '${_year(experience.startDate)}-${_year(experience.endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(
        14,
        16,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF211F20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppColors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.role.trim().isEmpty
                          ? 'Role'
                          : experience.role,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      experience.companyName.trim().isEmpty
                          ? 'Company'
                          : experience.companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),

                    if (experience.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        experience.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    if (experience.salary.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Salary: ${experience.salary}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Text(
                yearText,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color: AppColors.white.withOpacity(.10),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    controller.fillExperience(
                      experience,
                    );

                    Get.toNamed(
                      AppRoutes.addProfessional,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: AppColors.white,
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                height: 24,
                width: 1,
                color: AppColors.white.withOpacity(.20),
              ),

              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    controller.deleteExperience(
                      experience.id,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}