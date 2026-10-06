import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/medical_certificate_controller.dart';
import '../model/medical_certificate_model.dart';

class MedicalCertificateTable extends StatelessWidget {
  final List<MedicalCertificateModel> certificates;

  final Function(String url) onView;

  const MedicalCertificateTable({
    super.key,
    required this.certificates,
    required this.onView,
  });

  String _date(String value) {
    if (value.isEmpty) return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return value.length >= 10 ? value.substring(0, 10) : value;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isExpired(String expiryDate) {
    final date = DateTime.tryParse(expiryDate);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalCertificateController>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                _HeaderCell(text: 'Registration Date'),
                _HeaderCell(text: 'Expiry Date'),
                _HeaderCell(text: 'Status'),
                _HeaderCell(text: 'Document'),
              ],
            ),
          ),

          ...certificates.map((item) {
            final expired = _isExpired(item.expiryDate);

            return Container(
              height: 82,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.white.withOpacity(0.10),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _BodyCell(text: _date(item.registrationDate)),
                  _BodyCell(text: _date(item.expiryDate)),

                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: expired
                              ? const Color(0xFF5C0005)
                              : Colors.green.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          expired ? 'Expired' : 'Active',
                          style: TextStyle(
                            color: expired
                                ? const Color(0xFFFF6B6B)
                                : Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: IconButton(
                        onPressed: () => onView(item.document),
                        icon: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;

  const _BodyCell({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.lightGrey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}