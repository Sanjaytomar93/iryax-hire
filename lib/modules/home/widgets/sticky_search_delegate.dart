import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickySearchDelegate({
    required this.child,
  });

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(
      covariant StickySearchDelegate oldDelegate,
      ) {
    return oldDelegate.child != child;
  }
}