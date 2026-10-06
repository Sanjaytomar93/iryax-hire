import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/applications_controller.dart';
import '../model/application_model.dart';

class OfferLettersView extends GetView<ApplicationsController> {
  const OfferLettersView({super.key});

  static const Color _surfaceColor = Color(0xFF1D2232);
  static const Color _headerBlue = Color(0xFF164F84);
  static const Color _borderColor = Color(0xFF343C4F);
  static const Color _hintColor = Color(0xFF817D82);
  static const Color _secondaryText = Color(0xFFB8BECC);
  static const Color _offerGreen = Color(0xFF326D47);
  static const Color _offerTextGreen = Color(0xFF00F03B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: _headerBlue,
          onRefresh: controller.getAppliedJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              30,
              18,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 46),
                _buildSearchAndDate(context),
                const SizedBox(height: 22),
                _buildLettersContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Material(
          color: const Color(0xFF252526),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: Get.back,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Letters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndDate(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildSearchField(),
        ),
        const SizedBox(width: 7),
        _buildDateField(context),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 49,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller.offerSearchController,
        onChanged: controller.updateOfferSearch,
        cursorColor: Colors.white,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          hintText: 'Search By Role Or Type',
          hintStyle: const TextStyle(
            color: _hintColor,
            fontSize: 14,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 10,
            ),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: 25,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 49,
          ),
          suffixIcon: Obx(() {
            if (controller.offerSearchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: () {
                controller.offerSearchController.clear();
                controller.updateOfferSearch('');
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 18,
              ),
            );
          }),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 34,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context,
      ) {
    return Obx(() {
      final bool hasDate =
          controller.selectedOfferDate.value != null;

      return InkWell(
        onTap: () {
          controller.selectOfferLetterDate(context);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 49,
          constraints: const BoxConstraints(
            minWidth: 90,
            maxWidth: 116,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
          ),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  hasDate
                      ? controller.selectedOfferDateText
                      : 'July 03',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
              if (hasDate)
                GestureDetector(
                  onTap: controller.clearOfferDate,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 3),
                    child: Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLettersContent() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.applications.isEmpty) {
        return const SizedBox(
          height: 240,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        );
      }

      final List<ApplicationModel> letters =
          controller.filteredOfferLetters;

      if (letters.isEmpty) {
        return _buildEmptyState();
      }

      return _buildLettersTable(letters);
    });
  }

  Widget _buildLettersTable(
      List<ApplicationModel> letters,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          ...List.generate(
            letters.length,
                (index) {
              return _buildTableRow(
                application: letters[index],
                isLast: index == letters.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 38,
      color: _headerBlue,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 23,
            child: Text(
              'Role',
              style: TextStyle(
                color: Color(0xFFD7E2EE),
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: Text(
              'Document Type',
              style: TextStyle(
                color: Color(0xFFD7E2EE),
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            flex: 24,
            child: Text(
              'Issue Date',
              style: TextStyle(
                color: Color(0xFFD7E2EE),
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              'Action',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD7E2EE),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required ApplicationModel application,
    required bool isLast,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 56,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
          bottom: BorderSide(
            color: Color(0xFF252C3C),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 23,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                application.displayRole,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD7D9E0),
                  fontSize: 10,
                  height: 1.25,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _offerGreen,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      application.displayDocumentType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _offerTextGreen,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Tooltip(
                  message: 'Preview',
                  child: InkWell(
                    onTap: () {
                      controller.showOfferPreview(
                        application,
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 27,
                      height: 27,
                      child: Icon(
                        Icons.visibility_outlined,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 24,
            child: Text(
              application.formattedOfferDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD7D9E0),
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              tooltip: 'Actions',
              color: const Color(0xFF252C3D),
              surfaceTintColor: Colors.transparent,
              elevation: 8,

              position: PopupMenuPosition.under,

              offset: const Offset(
                -140,
                -2,
              ),

              constraints: const BoxConstraints(
                minWidth: 165,
                maxWidth: 190,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color(0xFF3B4559),
                  width: 0.8,
                ),
              ),

              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 20,
              ),

              onSelected: (String value) {
                switch (value) {
                  case 'preview':
                    controller.showOfferPreview(application);
                    break;

                  case 'download':
                    controller.downloadOfferLetter(application);
                    break;

                  case 'upload':
                    controller.showSignedOfferUploadDialog(
                      application,
                    );
                    break;

                  case 'submitted':
                    controller.downloadRemoteDocument(
                      remotePath: application.signedOfferPath,
                      fallbackName:
                      'signed_offer_${application.id}.pdf',
                    );
                    break;
                }
              },

              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'preview',
                    height: 46,
                    child: _OfferMenuItem(
                      icon: Icons.visibility_outlined,
                      title: 'Preview',
                    ),
                  ),

                  const PopupMenuDivider(
                    height: 1,
                  ),

                  const PopupMenuItem<String>(
                    value: 'download',
                    height: 46,
                    child: _OfferMenuItem(
                      icon: Icons.download_outlined,
                      title: 'Download',
                    ),
                  ),

                  const PopupMenuDivider(
                    height: 1,
                  ),

                  PopupMenuItem<String>(
                    value: 'upload',
                    height: 46,
                    child: _OfferMenuItem(
                      icon: Icons.upload_file_outlined,
                      title: application.hasSignedOffer
                          ? 'Resubmit'
                          : 'Sign & Submit',
                    ),
                  ),

                  if (application.hasSignedOffer) ...[
                    const PopupMenuDivider(
                      height: 1,
                    ),
                    const PopupMenuItem<String>(
                      value: 'submitted',
                      height: 46,
                      child: _OfferMenuItem(
                        icon: Icons.file_present_outlined,
                        title: 'Submitted File',
                      ),
                    ),
                  ],
                ];
              },
            )
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 290,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _borderColor,
          width: 0.7,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFF252C3D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Offer Letters Found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Offer letters sent by employers will\nappear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          Obx(() {
            final bool hasFilters =
                controller.offerSearchQuery.value.isNotEmpty ||
                    controller.selectedOfferDate.value != null;

            if (!hasFilters) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: OutlinedButton(
                onPressed: () {
                  controller.offerSearchController.clear();
                  controller.updateOfferSearch('');
                  controller.clearOfferDate();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF566074),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OfferMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _OfferMenuItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}