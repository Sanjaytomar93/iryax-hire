import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../controller/personal_documents_controller.dart';
import '../widgets/profile_form_field.dart';

class PersonalDocumentsView extends GetView<PersonalDocumentsController> {
  const PersonalDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED APP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(
                26,
                24,
                26,
                16,
              ),
              child: _topBar(),
            ),

            // SCROLLABLE CONTENT
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.documents.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.getCandidateDocuments,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      26,
                      20,
                      26,
                      44,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Identity Documents'),

                        _documentTile(
                          title: 'Upload Aadhar',
                          type: 'aadharCard',
                        ),

                        const SizedBox(height: 12),

                        _documentTile(
                          title: 'Upload PAN',
                          type: 'panCard',
                        ),

                        const SizedBox(height: 24),

                        _sectionTitle('Education'),

                        _documentTile(
                          title: '10TH CERTIFICATE',
                          type: 'tenthCertificate',
                        ),

                        const SizedBox(height: 12),

                        _documentTile(
                          title: '12TH CERTIFICATE',
                          type: 'twelfthCertificate',
                        ),

                        const SizedBox(height: 12),

                        _documentTile(
                          title: 'GRADUATION DEGREE',
                          type: 'graduationCertificate',
                        ),

                        const SizedBox(height: 24),

                        _sectionTitle('Identity Photo'),

                        _documentTile(
                          title: 'PASSPORT PHOTO',
                          type: 'passportPhoto',
                          imageOnly: true,
                        ),

                        const SizedBox(height: 38),

                        _sectionTitle('Bank Profile'),

                        _formCard(
                          children: [
                            ProfileFormField(
                              label: 'Bank Name',
                              hint: 'State Bank of India, Hyderabad',
                              controller: controller.bankNameController,
                            ),

                            const SizedBox(height: 22),

                            ProfileFormField(
                              label: 'Account Number',
                              hint: '1111 1111 1111',
                              controller: controller.accountNumberController,
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 22),

                            ProfileFormField(
                              label: 'IFSC Code',
                              hint: 'SBIN0005577',
                              controller: controller.ifscController,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        _sectionTitle('Emergency Contact'),

                        _formCard(
                          children: [
                            ProfileFormField(
                              label: 'Contact Name',
                              hint: 'Rajesh',
                              controller: controller.contactNameController,
                            ),

                            const SizedBox(height: 22),

                            ProfileFormField(
                              label: 'Phone Number',
                              hint: '+91 9666554422',
                              controller: controller.contactPhoneController,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 22),

                            ProfileFormField(
                              label: 'Relation',
                              hint: 'Father',
                              controller: controller.relationController,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: SizedBox(
                            width: 285,
                            height: 58,
                            child: Obx(
                                  () => PrimaryButton(
                                title: controller.isSaving.value
                                    ? 'Saving...'
                                    : 'Save',
                                onTap: controller.isSaving.value
                                    ? () {}
                                    : controller.saveDocuments,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TOP BAR
  // =============================================================

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Container(
            height: 56,
            width: 56,
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

        const SizedBox(width: 16),

        const Expanded(
          child: Text(
            'Personal Documents',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // SECTION TITLE
  // =============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // =============================================================
  // DOCUMENT TILE
  // =============================================================

  Widget _documentTile({
    required String title,
    required String type,
    bool imageOnly = false,
  }) {
    return Obx(() {
      final isUploading =
          controller.uploadingType.value == type;

      final document =
      controller.getDocument(type);

      final hasDocument =
          document?.isUploaded == true;

      final displayTitle =
      controller.documentTitle(
        type: type,
        defaultTitle: title,
      );

      final status =
      controller.documentStatus(type);

      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 66,
        ),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isUploading
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        )
            : Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
            BorderRadius.circular(10),

            // Uploaded document -> Preview
            // Not uploaded -> Select file
            onTap:
            controller.uploadingType.value.isNotEmpty
                ? null
                : () {
              if (hasDocument) {
                controller
                    .previewDocument(type);
              } else {
                controller
                    .pickAndUploadDocument(
                  type: type,
                  imageOnly: imageOnly,
                );
              }
            },

            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Row(
                children: [
                  Icon(
                    hasDocument
                        ? Icons
                        .description_outlined
                        : Icons
                        .file_upload_outlined,
                    color: hasDocument
                        ? AppColors.white
                        : AppColors.greyText,
                    size: 27,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style: TextStyle(
                            color:
                            hasDocument
                                ? AppColors
                                .white
                                : AppColors
                                .greyText,
                            fontSize: 16,
                            fontWeight:
                            FontWeight
                                .w500,
                          ),
                        ),

                        if (status
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 4,
                          ),

                          Row(
                            children: [
                              Icon(
                                status ==
                                    'Verified'
                                    ? Icons
                                    .verified
                                    : Icons
                                    .check_circle_outline,
                                color:
                                status ==
                                    'Verified'
                                    ? Colors
                                    .green
                                    : Colors
                                    .greenAccent,
                                size: 14,
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Text(
                                status,
                                style:
                                TextStyle(
                                  color:
                                  status ==
                                      'Verified'
                                      ? Colors
                                      .green
                                      : Colors
                                      .greenAccent,
                                  fontSize:
                                  11,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (hasDocument) ...[
                    // PREVIEW
                    GestureDetector(
                      behavior:
                      HitTestBehavior
                          .opaque,
                      onTap: () {
                        controller
                            .previewDocument(
                          type,
                        );
                      },
                      child: const Padding(
                        padding:
                        EdgeInsets.all(
                          8,
                        ),
                        child: Icon(
                          Icons
                              .visibility_outlined,
                          color:
                          AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 2),

                    // EDIT / RE-UPLOAD
                    GestureDetector(
                      behavior:
                      HitTestBehavior
                          .opaque,
                      onTap: () {
                        controller
                            .pickAndUploadDocument(
                          type: type,
                          imageOnly:
                          imageOnly,
                        );
                      },
                      child: const Padding(
                        padding:
                        EdgeInsets.all(
                          8,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color:
                          AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // =============================================================
  // FORM CARD
  // =============================================================

  Widget _formCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}