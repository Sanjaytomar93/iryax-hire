import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../home/widgets/job_company_logo.dart';
import '../controller/apply_job_controller.dart';

class ApplyJobView extends GetView<ApplyJobController> {
  const ApplyJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(74),
          child: SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.black,
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                8,
              ),
              child: _topBar(),
            ),
          ),
        ),
        body: controller.isProfileLoading.value
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        )
            : Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              50,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _jobCard(),

                const SizedBox(height: 30),

                const Text(
                  'Upload Resume',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 14),

                _UploadTile(
                  title: controller.resume.value == null
                      ? 'Upload File'
                      : _fileName(
                    controller.resume.value!.path,
                  ),
                  subtitle:
                  controller.resume.value == null
                      ? '(PDF, DOC, DOCX)'
                      : '',
                  onTap: controller.pickResume,
                ),

                const SizedBox(height: 30),

                const Text(
                  'Basic Information',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                _ExpandableSection(
                  title: 'Personal Details',
                  expanded:
                  controller.personalExpanded.value,
                  onTap:
                  controller.togglePersonalSection,
                  child: _personalDetails(),
                ),

                _ExpandableSection(
                  title: 'Education Details',
                  expanded:
                  controller.educationExpanded.value,
                  onTap:
                  controller.toggleEducationSection,
                  child: _educationDetails(),
                ),

                _ExpandableSection(
                  title: 'Professional Details',
                  expanded:
                  controller.professionalExpanded.value,
                  onTap:
                  controller.toggleProfessionalSection,
                  child: _professionalDetails(context),
                ),

                const SizedBox(height: 50),

                Center(
                  child: SizedBox(
                    width: 190,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      controller.isLoading.value
                          ? null
                          : controller
                          .submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primary,
                        disabledBackgroundColor:
                        AppColors.primary
                            .withOpacity(.60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      child:
                      controller.isLoading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                          : const Text(
                        'Apply',
                        style: TextStyle(
                          color:
                          AppColors.white,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: Get.back,
          child: Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: Color(0xFF211F20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 25,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Apply',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _jobCard() {
    final job = controller.job;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        17,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2D2D3A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          JobCompanyLogo(
            companyName: job.companyName,
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
                    fontSize: 12.5,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${job.location.trim().isEmpty ? 'India' : job.location}'
                      '   •   '
                      '${job.jobType.trim().isEmpty ? 'Onsite' : job.jobType}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalDetails() {
    return Column(
      children: [
        _AppTextField(
          label: 'Full Name',
          controller: controller.fullNameController,
          hint: 'Enter full name',
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator(
            'Please enter full name',
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Email',
          controller: controller.emailController,
          hint: 'Enter email address',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final email = value?.trim() ?? '';

            if (email.isEmpty) {
              return 'Please enter email address';
            }

            if (!GetUtils.isEmail(email)) {
              return 'Please enter a valid email address';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Mobile Number',
          controller: controller.mobileController,
          hint: 'Enter mobile number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          validator: (value) {
            final mobile = value?.trim() ?? '';

            if (mobile.isEmpty) {
              return 'Please enter mobile number';
            }

            if (mobile.length < 10) {
              return 'Please enter a valid mobile number';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Address',
          controller: controller.addressController,
          hint: 'Enter complete address',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 3,
          validator: _requiredValidator(
            'Please enter address',
          ),
        ),
      ],
    );
  }

  Widget _educationDetails() {
    return Column(
      children: [
        Obx(
              () => _AppDropdown(
            label: 'Highest Qualification',
            value:
            controller.selectedQualification.value,
            hint: 'Select qualification',
            items: _withCurrentValue(
              controller.qualificationOptions,
              controller.selectedQualification.value,
            ),
            onChanged: (value) {
              controller.selectedQualification.value =
                  value ?? '';
            },
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Institution / College',
          controller:
          controller.institutionController,
          hint: 'Enter institution or college',
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator(
            'Please enter institution or college',
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Department / Stream',
          controller:
          controller.departmentController,
          hint: 'Example: CSE',
          textCapitalization:
          TextCapitalization.characters,
          validator: _requiredValidator(
            'Please enter department or stream',
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Percentage / CGPA',
          controller:
          controller.percentageController,
          hint: 'Example: 80 or 7.8',
          keyboardType:
          const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'),
            ),
          ],
          validator: _requiredValidator(
            'Please enter percentage or CGPA',
          ),
        ),

        const SizedBox(height: 16),

        Obx(
              () => _AppDropdown(
            label: 'Passing Year',
            value:
            controller.selectedPassingYear.value,
            hint: 'Select passing year',
            items: _withCurrentValue(
              controller.passingYearOptions,
              controller.selectedPassingYear.value,
            ),
            onChanged: (value) {
              controller.selectedPassingYear.value =
                  value ?? '';
            },
          ),
        ),
      ],
    );
  }

  Widget _professionalDetails(BuildContext context) {
    return Column(
      children: [
        _AppTextField(
          label: 'Current Company',
          controller:
          controller.currentCompanyController,
          hint: 'Enter current company',
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator(
            'Please enter current company',
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Current Role / Designation',
          controller:
          controller.currentRoleController,
          hint: 'Selected job role',
          readOnly: true,
        ),

        const SizedBox(height: 16),

        Obx(
              () => _AppDropdown(
            label: 'Total Experience (Years)',
            value:
            controller.selectedExperience.value,
            hint: 'Select total experience',
            items: _withCurrentValue(
              controller.experienceOptions,
              controller.selectedExperience.value,
            ),
            onChanged: (value) {
              controller.selectedExperience.value =
                  value ?? '';
            },
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Current Location',
          controller:
          controller.currentLocationController,
          hint: 'Enter current location',
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator(
            'Please enter current location',
          ),
        ),

        const SizedBox(height: 16),

        Obx(
              () => _AppDropdown(
            label: 'Current CTC',
            value:
            controller.selectedCurrentCTC.value,
            hint: 'Select current CTC',
            items: _withCurrentValue(
              controller.ctcOptions,
              controller.selectedCurrentCTC.value,
            ),
            onChanged: (value) {
              controller.selectedCurrentCTC.value =
                  value ?? '';
            },
          ),
        ),

        const SizedBox(height: 16),

        Obx(
              () => _AppDropdown(
            label: 'Expected CTC',
            value:
            controller.selectedExpectedCTC.value,
            hint: 'Select expected CTC',
            items: _withCurrentValue(
              controller.ctcOptions,
              controller.selectedExpectedCTC.value,
            ),
            onChanged: (value) {
              controller.selectedExpectedCTC.value =
                  value ?? '';
            },
          ),
        ),

        const SizedBox(height: 16),

        Obx(
              () => _AppDropdown(
            label: 'Notice Period (Days)',
            value:
            controller.selectedNoticePeriod.value,
            hint: 'Select notice period',
            items: _withCurrentValue(
              controller.noticePeriodOptions,
              controller.selectedNoticePeriod.value,
            ),
            itemLabelBuilder: (value) {
              if (value == 'Immediate') {
                return 'Immediate';
              }

              return '$value Days';
            },
            onChanged: (value) {
              controller.selectedNoticePeriod.value =
                  value ?? '';
            },
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Preferred Join Date',
          controller:
          controller.joiningDateController,
          hint: 'Select preferred joining date',
          prefixIcon: Icons.calendar_month_outlined,
          readOnly: true,
          onTap: () =>
              controller.selectJoiningDate(context),
          validator: _requiredValidator(
            'Please select preferred joining date',
          ),
        ),

        const SizedBox(height: 16),

        _AppTextField(
          label: 'Key Skills (Comma Separated)',
          controller: controller.skillsController,
          hint: 'Flutter, Dart, GetX, Firebase',
          maxLines: 3,
          textCapitalization: TextCapitalization.words,
          validator: _requiredValidator(
            'Please enter key skills',
          ),
        ),
      ],
    );
  }

  List<String> _withCurrentValue(
      List<String> items,
      String currentValue,
      ) {
    final value = currentValue.trim();

    if (value.isEmpty || items.contains(value)) {
      return items;
    }

    return [
      value,
      ...items,
    ];
  }

  String? Function(String?) _requiredValidator(
      String message,
      ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }

      return null;
    };
  }

  String _fileName(String path) {
    return path.split('/').last.split('\\').last;
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 64,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                  AppColors.white.withOpacity(.25),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration:
                  const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: expanded
              ? Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              20,
              0,
              22,
            ),
            child: child,
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.upload_file_outlined,
              color: AppColors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.label,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization =
        TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
              prefixIcon,
              color: AppColors.greyText,
              size: 21,
            ),
            suffixIcon: readOnly && onTap != null
                ? const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.greyText,
            )
                : null,
            filled: true,
            fillColor: AppColors.field,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppDropdown extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? itemLabelBuilder;

  const _AppDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final validValue =
    value.isNotEmpty && items.contains(value)
        ? value
        : null;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: validValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A2133),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.greyText,
          ),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.field,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
          ),
          hint: Text(
            hint,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                itemLabelBuilder?.call(item) ?? item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}