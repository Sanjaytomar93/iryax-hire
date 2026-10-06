import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/assessment_controller.dart';

class AssessmentView extends GetView<AssessmentController> {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            );
          }

          final data = controller.assessment.value;

          if (data == null || data.questions.isEmpty) {
            return const Center(
              child: Text(
                'No assessment available',
                style: TextStyle(color: AppColors.white),
              ),
            );
          }

          if (!controller.hasStarted.value) {
            return _instructionsView(data.title, data.duration);
          }

          final question = data.questions[controller.currentIndex.value];
          final selected = controller.selectedAnswers[question.id];

          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar('Assessment'),

                const SizedBox(height: 28),

                Text(
                  data.title.isEmpty ? 'Assessment' : data.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Question ${controller.currentIndex.value + 1} of ${data.questions.length}',
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  question.questionText,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                ...question.options.map(
                      (option) => _optionTile(
                    option: option,
                    selected: selected == option,
                    onTap: () => controller.selectAnswer(question.id, option),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    )
                        : Text(
                      controller.currentIndex.value ==
                          data.questions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _instructionsView(String title, int duration) {
    final assessmentTitle =
    title.isEmpty ? 'Freshers General Assessment' : title;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: _topBar('Assessment Instructions'),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Hello! We’re excited to evaluate your skills\nfor the $assessmentTitle phase.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: const [
                      _InstructionRow(
                        number: '1',
                        text:
                        'Multiple Choice Questions (MCQ) format with unique options.',
                      ),
                      _InstructionRow(
                        number: '2',
                        text:
                        'No negative marking. Feel free to attempt all questions.',
                      ),
                      _InstructionRow(
                        number: '3',
                        text:
                        'Click “Next” to proceed. You can revisit previous questions.',
                      ),
                      _InstructionRow(
                        number: '4',
                        text:
                        'Click “Finish” once all questions are answered.',
                        showBottomSpace: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7A3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: Color(0xFFFFB300),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'THE TIMER (${duration == 0 ? 10 : duration}MINS) WILL START ONCE YOU CLICK START.',
                          style: const TextStyle(
                            color: Color(0xFF5E4A0A),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: controller.startAssessment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Assessment Now',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _topBar(String title) {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            height: 38,
            width: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _optionTile({
    required String option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFF171717),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFF34343D),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: AppColors.white,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;
  final bool showBottomSpace;

  const _InstructionRow({
    required this.number,
    required this.text,
    this.showBottomSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpace ? 20 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF242222),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}