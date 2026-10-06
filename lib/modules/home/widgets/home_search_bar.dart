import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFilterSelected;
  final String selectedFilter;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterSelected,
    this.selectedFilter = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(
        left: 16,
        right: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.greyText,
            size: 24,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.white,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search for the Jobs...',
                hintStyle: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          PopupMenuButton<String>(
            color: const Color(0xFF171717),
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.greyText,
              size: 21,
            ),
            onSelected: onFilterSelected,
            itemBuilder: (_) => [
              _item(
                'All Jobs',
                '',
              ),
              _item(
                'Normal Jobs',
                'normal',
              ),
              _item(
                'Short Jobs',
                'short',
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _item(
      String title,
      String value,
      ) {
    final selected =
        selectedFilter == value;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.white
                    : AppColors.greyText,
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),

          if (selected)
            const Icon(
              Icons.check,
              color: AppColors.white,
              size: 17,
            ),
        ],
      ),
    );
  }
}