import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/main_bottom_nav.dart';
import '../../home/model/job_model.dart';
import '../../home/widgets/job_company_logo.dart';
import '../controller/application_details_controller.dart';
import '../model/application_model.dart';
import '../model/application_timeline_item.dart';

class ApplicationDetailsView
    extends GetView<ApplicationDetailsController> {
  const ApplicationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      bottomNavigationBar: const MainBottomNav(
        currentIndex: 3,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              6,
            ),
            child: _topBar(),
          ),
        ),
      ),
      body: Obx(
            () {
          if (controller.isLoading.value &&
              controller.application.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            );
          }

          if (controller.error.value.isNotEmpty &&
              controller.application.value == null) {
            return _ErrorState(
              message: controller.error.value,
              onRetry: controller.getApplicationDetails,
            );
          }

          final application =
              controller.application.value;

          if (application == null) {
            return const _ErrorState(
              message:
              'Application details are unavailable',
            );
          }

          return RefreshIndicator(
            color: AppColors.black,
            backgroundColor: AppColors.white,
            onRefresh: controller.getApplicationDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                30,
                16,
                30,
                110,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ApplicationHeaderCard(
                    job: application.job,
                    status: controller.displayStatus,
                  ),

                  const SizedBox(height: 30),

                  _ApplicationTimeline(
                    items: controller.timelineItems,
                    fallbackDate: application.createdAt,
                    onInterviewTap: (title) {
                      _showInterviewResponseDialog(
                        title: title,
                      );
                    },
                    onViewApplication: () {
                      final job = application.job;

                      if (job.id.isEmpty) {
                        return;
                      }

                      Get.toNamed(
                        AppRoutes.jobDetails,
                        arguments: job.copyWith(
                          isApplied: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
          },
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: Get.back,
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF242223),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 27,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Text(
            'Applications',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Container(
          height: 44,
          width: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF242223),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.white,
                  size: 23,
                ),
              ),
              Positioned(
                right: 9,
                top: 8,
                child: Container(
                  height: 7,
                  width: 7,
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

  void _showInterviewResponseDialog({
    required String title,
  }) {
    final ApplicationInterviewModel? interview =
        controller.effectiveInterview;

    if (interview == null ||
        !interview.hasSchedule) {
      Get.snackbar(
        'Interview',
        'Interview schedule is not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF252525),
        colorText: AppColors.white,
      );
      return;
    }

    controller.interviewNoteController.clear();

    Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: Obx(
              () {
            final ApplicationInterviewModel?
            currentInterview =
                controller.effectiveInterview;

            if (currentInterview == null) {
              return const SizedBox.shrink();
            }

            final bool isConfirmed =
                controller.isInterviewConfirmed;

            final bool isDeclined =
                controller.isInterviewDeclined;

            final bool isResponding =
                controller
                    .isRespondingToInterview.value;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.82,
              ),
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF363636),
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior:
                          HitTestBehavior.opaque,
                          onTap: isResponding
                              ? null
                              : Get.back,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration:
                            const BoxDecoration(
                              color: Color(0xFF262626),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please confirm whether you are available for this interview.',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _InterviewScheduleCard(
                      interview: currentInterview,
                    ),

                    if (isConfirmed ||
                        isDeclined) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isConfirmed
                              ? const Color(0xFF123A1D)
                              : const Color(0xFF493314),
                          borderRadius:
                          BorderRadius.circular(9),
                        ),
                        child: Text(
                          isConfirmed
                              ? 'You confirmed this interview.'
                              : 'You declined this interview. A reschedule was requested.',
                          style: TextStyle(
                            color: isConfirmed
                                ? const Color(0xFF68D578)
                                : const Color(0xFFFFB74D),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],

                    if (!isConfirmed &&
                        !isDeclined) ...[
                      const SizedBox(height: 18),

                      TextField(
                        controller: controller
                            .interviewNoteController,
                        enabled: !isResponding,
                        minLines: 2,
                        maxLines: 4,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText:
                          'Add an optional note or decline reason',
                          hintStyle:
                          const TextStyle(
                            color:
                            AppColors.greyText,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor:
                          const Color(0xFF222222),
                          contentPadding:
                          const EdgeInsets.all(14),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                            borderSide:
                            const BorderSide(
                              color:
                              Color(0xFF3A3A3A),
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                            borderSide:
                            const BorderSide(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isResponding
                                  ? null
                                  : () async {
                                final String note =
                                controller
                                    .interviewNoteController
                                    .text
                                    .trim();

                                final bool success =
                                await controller
                                    .respondToInterview(
                                  status:
                                  'Declined',
                                  note: note.isEmpty
                                      ? 'Unable to attend the scheduled interview. Please reschedule.'
                                      : note,
                                );

                                if (success &&
                                    Get.isDialogOpen ==
                                        true) {
                                  Get.back<void>();
                                }
                              },
                              style: OutlinedButton
                                  .styleFrom(
                                minimumSize:
                                const Size
                                    .fromHeight(46),
                                foregroundColor:
                                AppColors.white,
                                disabledForegroundColor:
                                AppColors.greyText,
                                side:
                                const BorderSide(
                                  color:
                                  Color(0xFF555555),
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(9),
                                ),
                              ),
                              child: const Text(
                                'Decline',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isResponding
                                  ? null
                                  : () async {
                                final String note =
                                controller
                                    .interviewNoteController
                                    .text
                                    .trim();

                                final bool success =
                                await controller
                                    .respondToInterview(
                                  status:
                                  'Confirmed',
                                  note: note.isEmpty
                                      ? 'I am available for the interview at the scheduled time'
                                      : note,
                                );

                                if (success &&
                                    Get.isDialogOpen ==
                                        true) {
                                  Get.back<void>();
                                }
                              },
                              style: ElevatedButton
                                  .styleFrom(
                                minimumSize:
                                const Size
                                    .fromHeight(46),
                                backgroundColor:
                                AppColors.white,
                                foregroundColor:
                                AppColors.black,
                                disabledBackgroundColor:
                                const Color(
                                  0xFF555555,
                                ),
                                disabledForegroundColor:
                                AppColors.greyText,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(9),
                                ),
                              ),
                              child: isResponding
                                  ? const SizedBox(
                                height: 19,
                                width: 19,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                  AppColors.black,
                                ),
                              )
                                  : const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible:
      !controller.isRespondingToInterview.value,
    );
  }


}

class _InterviewScheduleCard extends StatelessWidget {
  final ApplicationInterviewModel interview;

  const _InterviewScheduleCard({
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF343434),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScheduleItem(
            icon: interview.isOnline
                ? Icons.videocam_outlined
                : Icons.location_on_outlined,
            title: 'Interview Mode',
            value:
            interview.isOnline ? 'Online' : 'Offline',
          ),

          if (interview.scheduledAt != null) ...[
            const SizedBox(height: 13),
            _ScheduleItem(
              icon: Icons.calendar_month_outlined,
              title: 'Date & Time',
              value: DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(
                interview.scheduledAt!.toLocal(),
              ),
            ),
          ],

          if (interview.isOnline &&
              interview.link.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            _ScheduleItem(
              icon: Icons.link,
              title: 'Meeting Link',
              value: interview.link,
            ),
          ] else if (interview.address.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            _ScheduleItem(
              icon: Icons.location_on_outlined,
              title: 'Address',
              value: interview.address,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ScheduleItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.greyText,
          size: 18,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 10.5,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApplicationHeaderCard extends StatelessWidget {
  final JobModel job;
  final String status;

  const _ApplicationHeaderCard({
    required this.job,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        15,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF34343E),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 52,
                width: 52,
                child: JobCompanyLogo(
                  companyName: job.companyName,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName.trim().isEmpty
                          ? 'Company'
                          : job.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      job.role.trim().isEmpty
                          ? 'Job Role'
                          : job.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.location.trim().isEmpty
                                ? 'India'
                                : job.location,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.greyText,
                              fontSize: 11.5,
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        Text(
                          _formatJobType(job.jobType),
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(
            height: 1,
            thickness: 0.8,
            color: AppColors.white.withOpacity(.28),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFAAAAAA),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD6D6D6),
                    width: 1.8,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatJobType(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    if (normalized.isEmpty ||
        normalized == 'normal') {
      return 'Onsite';
    }

    return normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }
}
class _ApplicationTimeline extends StatelessWidget {
  final List<ApplicationTimelineItem> items;
  final DateTime? fallbackDate;
  final VoidCallback onViewApplication;
  final ValueChanged<String> onInterviewTap;

  const _ApplicationTimeline({
    required this.items,
    required this.fallbackDate,
    required this.onViewApplication,
    required this.onInterviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 34,
        right: 4,
      ),
      child: Column(
        children: List.generate(
          items.length,
              (index) {
            final item = items[index];
            final isLast = index == items.length - 1;

            return _TimelineRow(
              item: item,
              isFirst: index == 0,
              isLast: isLast,
              fallbackDate: isLast ? fallbackDate : null,
              onViewApplication:
              isLast ? onViewApplication : null,
              onTap: item.hasInterviewSchedule
                  ? () => onInterviewTap(item.title)
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final ApplicationTimelineItem item;
  final bool isFirst;
  final bool isLast;
  final DateTime? fallbackDate;
  final VoidCallback? onViewApplication;
  final VoidCallback? onTap;

  const _TimelineRow({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.fallbackDate,
    required this.onViewApplication,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime? displayDate =
        item.timestamp ?? fallbackDate;

    final bool showInterviewDetails =
        item.hasInterviewSchedule;

    final double rowHeight = isLast
        ? 102
        : showInterviewDetails
        ? 104
        : 72;

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: rowHeight - 22,
                    child: Container(
                      width: 1.6,
                      color: _lineColor(),
                    ),
                  ),

                if (!isLast)
                  Positioned(
                    top: 22,
                    bottom: 0,
                    child: Container(
                      width: 1.6,
                      color: _lineColor(),
                    ),
                  ),

                Positioned(
                  top: 0,
                  child: _TimelineIndicator(
                    isCompleted: item.isCompleted,
                    isCurrent: item.isCurrent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14.5,
                              height: 1.15,
                              fontWeight: FontWeight.w400,
                              decoration: onTap != null
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: AppColors.white,
                            ),
                          ),
                        ),
                        if (onTap != null) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.touch_app_outlined,
                            color: AppColors.greyText,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (showInterviewDetails) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onTap,
                      child: Text(
                        _interviewScheduleText(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ] else if (displayDate != null && isLast) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(displayDate),
                      style: const TextStyle(
                        color: AppColors.greyText,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ],

                  if (isLast &&
                      onViewApplication != null) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onViewApplication,
                      child: const Text(
                        'View Application',
                        style: TextStyle(
                          color: Color(0xFF0099FF),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF0099FF),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _interviewScheduleText() {
    final List<String> details = [];

    if (item.timestamp != null) {
      details.add(
        DateFormat(
          'MMMM d, h:mm a',
        ).format(
          item.timestamp!.toLocal(),
        ),
      );
    }

    if (item.interviewAddress.trim().isNotEmpty) {
      details.add(item.interviewAddress.trim());
    } else if (item.interviewLink.trim().isNotEmpty) {
      details.add(item.interviewLink.trim());
    }

    if (details.isEmpty) {
      return 'Interview scheduled';
    }

    return 'Scheduled for ${details.join(', ')}';
  }

  Color _lineColor() {
    return item.isCompleted
        ? const Color(0xFF48B957)
        : AppColors.white;
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat(
      'd MMM yyyy, h:mm a',
    ).format(dateTime.toLocal());
  }
}
class _TimelineIndicator extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;

  const _TimelineIndicator({
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        height: 26,
        width: 26,
        decoration: const BoxDecoration(
          color: Color(0xFF48B957),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: AppColors.white,
          size: 17,
        ),
      );
    }

    return Container(
      height: 19,
      width: 19,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 2,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.greyText,
              size: 44,
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 18),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}