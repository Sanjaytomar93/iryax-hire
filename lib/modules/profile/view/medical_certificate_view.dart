import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/medical_certificate_controller.dart';
import '../widgets/medical_certificate_table.dart';

class MedicalCertificateView
    extends GetView<MedicalCertificateController> {
  const MedicalCertificateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  28,
                  24,
                  36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(),

                    const SizedBox(height: 42),

                    const Text(
                      'Health Profile Data',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildMedicalForm(context),

                    const SizedBox(height: 30),

                    _buildSubmitButton(),

                    const SizedBox(height: 32),

                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 50,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                            ),
                          ),
                        );
                      }

                      if (controller.certificates.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 50,
                          ),
                          child: Center(
                            child: Text(
                              'No medical certificates added',
                              style: TextStyle(
                                color: AppColors.greyText,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      return MedicalCertificateTable(
                        certificates: controller.certificates,
                        onView: _showCertificatePreview,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FORM
  // =========================================================

  Widget _buildMedicalForm(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        22,
        18,
        24,
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
              Expanded(
                child: _dateField(
                  context: context,
                  label: 'Registration Date',
                  controller:
                  controller.registrationDateController,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _dateField(
                  context: context,
                  label: 'Expire Date',
                  controller:
                  controller.expiryDateController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _uploadDocumentButton(),
        ],
      ),
    );
  }

  // =========================================================
  // DATE FIELD
  // =========================================================


  // =========================================================
// DATE FIELD
// =========================================================

  Widget _dateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _pickDate(
              context,
              controller,
            );
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF312F30),
              borderRadius: BorderRadius.circular(10),
            ),

            // Automatically rebuilds when controller.text changes
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (
                  context,
                  value,
                  child,
                  ) {
                final selectedDate =
                value.text.trim();

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate.isEmpty
                            ? 'DD-MM-YYYY'
                            : selectedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedDate.isEmpty
                              ? AppColors.greyText
                              : AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

// =========================================================
// DATE PICKER
// Year -> Month -> Date
// =========================================================

  Future<void> _pickDate(
      BuildContext context,
      TextEditingController textController,
      ) async {
    DateTime initialDate = DateTime.now();

    // Use already selected date when reopening picker
    if (textController.text.trim().isNotEmpty) {
      try {
        final parts =
        textController.text.trim().split('-');

        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {
        initialDate = DateTime.now();
      }
    }

    // STEP 1: SELECT YEAR
    final selectedYear =
    await _selectYear(
      context,
      initialDate.year,
    );

    if (selectedYear == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    // STEP 2: SELECT MONTH
    final selectedMonth =
    await _selectMonth(
      context,
      initialDate.month,
    );

    if (selectedMonth == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    // STEP 3: SELECT DATE
    final lastDayOfMonth = DateTime(
      selectedYear,
      selectedMonth + 1,
      0,
    ).day;

    int initialDay = initialDate.day;

    if (initialDay > lastDayOfMonth) {
      initialDay = lastDayOfMonth;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
        selectedYear,
        selectedMonth,
        initialDay,
      ),
      firstDate: DateTime(
        selectedYear,
        selectedMonth,
        1,
      ),
      lastDate: DateTime(
        selectedYear,
        selectedMonth,
        lastDayOfMonth,
      ),
      initialDatePickerMode:
      DatePickerMode.day,
    );

    if (picked == null) {
      return;
    }

    // Update controller.
    // ValueListenableBuilder immediately updates the UI.
    textController.text =
    '${picked.day.toString().padLeft(2, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.year}';
  }

// =========================================================
// YEAR PICKER
// =========================================================

  Future<int?> _selectYear(
      BuildContext context,
      int initialYear,
      ) async {
    int selectedYear = initialYear;

    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
          const Color(0xFF211F20),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 450,
            width: 320,
            child: Column(
              children: [
                const Padding(
                  padding:
                  EdgeInsets.all(18),
                  child: Text(
                    'Select Year',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),

                Expanded(
                  child: YearPicker(
                    firstDate:
                    DateTime(1970),
                    lastDate:
                    DateTime(2100),
                    selectedDate:
                    DateTime(
                      initialYear,
                    ),
                    onChanged: (date) {
                      selectedYear =
                          date.year;

                      Navigator.pop(
                        dialogContext,
                        selectedYear,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// =========================================================
// MONTH PICKER
// =========================================================

  Future<int?> _selectMonth(
      BuildContext context,
      int initialMonth,
      ) async {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
          const Color(0xFF211F20),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Text(
                  'Select Month',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                GridView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount:
                  months.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder:
                      (context, index) {
                    final month =
                        index + 1;

                    final isSelected =
                        month ==
                            initialMonth;

                    return InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                          month,
                        );
                      },
                      child: Container(
                        alignment:
                        Alignment.center,
                        decoration:
                        BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(
                            0xFF312F30,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          months[index],
                          style:
                          const TextStyle(
                            color:
                            AppColors.white,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _dateField({
  //   required BuildContext context,
  //   required String label,
  //   required TextEditingController controller,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           color: AppColors.white,
  //           fontSize: 12,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //
  //       const SizedBox(height: 10),
  //
  //       GestureDetector(
  //         onTap: () => _pickDate(
  //           context,
  //           controller,
  //         ),
  //         child: Container(
  //           height: 52,
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: 14,
  //           ),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF312F30),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   controller.text.isEmpty
  //                       ? 'DD-MM-YYYY'
  //                       : controller.text,
  //                   maxLines: 1,
  //                   style: TextStyle(
  //                     color: controller.text.isEmpty
  //                         ? AppColors.greyText
  //                         : AppColors.white,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //               ),
  //
  //               const SizedBox(width: 5),
  //
  //               const Icon(
  //                 Icons.calendar_month_outlined,
  //                 color: AppColors.white,
  //                 size: 24,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Future<void> _pickDate(
  //     BuildContext context,
  //     TextEditingController textController,
  //     ) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(1970),
  //     lastDate: DateTime(2100),
  //   );
  //
  //   if (picked != null) {
  //     textController.text =
  //     '${picked.day.toString().padLeft(2, '0')}-'
  //         '${picked.month.toString().padLeft(2, '0')}-'
  //         '${picked.year}';
  //
  //     // Required because the date text is inside
  //     // a normal Text widget instead of TextFormField.
  //     controller.update();
  //   }
  // }

  // =========================================================
  // UPLOAD
  // =========================================================

  Widget _uploadDocumentButton() {
    return InkWell(
      onTap: controller.pickDocument,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF242223),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              color: AppColors.white,
              size: 25,
            ),
            SizedBox(width: 12),
            Text(
              'Upload Document',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: 240,
        height: 48,
        child: Obx(
              () => ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : controller.uploadMedicalCertificate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
              AppColors.primary.withOpacity(.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: controller.isSaving.value
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
                : const Text(
              'Submit',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PREVIEW
  // =========================================================

  void _showCertificatePreview(
      String documentUrl,
      ) {
    if (documentUrl.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Certificate file not available',
      );
      return;
    }

    final fullUrl = documentUrl.startsWith('http')
        ? documentUrl
        : 'https://ingrainhirebackend.ingrainsystems.com'
        '$documentUrl';

    final isPdf =
    fullUrl.toLowerCase().contains('.pdf');

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.chipGrey,
        insetPadding: const EdgeInsets.all(14),
        child: SizedBox(
          height: Get.height * 0.82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  12,
                  8,
                  12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Certificate Preview',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isPdf
                    ? SfPdfViewer.network(fullUrl)
                    : InteractiveViewer(
                  child: Image.network(
                    fullUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Center(
                        child: Text(
                          'Unable to load document',
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _topBar() {
    return Row(
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

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Medical Certificate',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}