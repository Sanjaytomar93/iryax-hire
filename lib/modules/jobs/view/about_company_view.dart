import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../home/model/job_model.dart';
import '../../home/widgets/job_card_widget.dart';
import '../../home/widgets/job_company_logo.dart';

class AboutCompanyView extends StatelessWidget {
  const AboutCompanyView({super.key});

  @override
  Widget build(BuildContext context) {
    final JobModel job = Get.arguments as JobModel;

    return Scaffold(
      backgroundColor: AppColors.black,

      // Fixed header
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
            child: _topBar(),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          22,
          14,
          22,
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

                const SizedBox(width: 14),

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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _smallInfo(
                        Icons.location_on_outlined,
                        job.location.isEmpty
                            ? 'Office Address'
                            : job.location,
                      ),

                      const SizedBox(height: 10),

                      _smallInfo(
                        Icons.people_outline,
                        job.department.isEmpty
                            ? '1500 Employees'
                            : job.department,
                      ),

                      const SizedBox(height: 10),

                      _smallInfo(
                        Icons.business_outlined,
                        job.jobType.isEmpty
                            ? 'Industry / Services'
                            : job.jobType,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            _sectionTitle(
              'About ${job.companyName.isEmpty ? 'Company' : job.companyName}',
            ),

            const SizedBox(height: 10),

            _paragraph(
              job.aboutCompany.isEmpty
                  ? 'Company details not available.'
                  : job.aboutCompany,
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              'Company Culture',
            ),

            const SizedBox(height: 10),

            _bulletList(
              const [
                'Professional work environment',
                'Good learning opportunities',
                'Team collaboration and growth focused culture',
                'Employee friendly workplace',
              ],
            ),

            const SizedBox(height: 24),

            Divider(
              color: AppColors.white.withOpacity(.22),
            ),

            const SizedBox(height: 18),

            _sectionTitle(
              'Similar Jobs For You',
            ),

            const SizedBox(height: 14),

            JobCardWidget(
              job: job,
              onSaveTap: () {},
            ),
          ],
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
            'About Company',
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
          child: const Icon(
            Icons.bookmark_border,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _smallInfo(
      IconData icon,
      String text,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.greyText,
          size: 17,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

  Widget _sectionTitle(
      String text,
      ) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _paragraph(
      String text,
      ) {
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