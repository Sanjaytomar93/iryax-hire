import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_history_model.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

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

          final wallet = controller.wallet.value;

          if (wallet == null) {
            return const Center(
              child: Text(
                'Wallet not found',
                style: TextStyle(color: AppColors.greyText),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 28),

                _BalanceCard(
                  coins: controller.totalCoins,
                  name: wallet.name,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'TOTAL EARNED',
                        value: controller.totalEarned.toString(),
                        suffix: 'coins',
                        icon: Icons.add_circle_outline,
                        iconColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'TOTAL SPENT',
                        value: controller.totalSpent.toString(),
                        suffix: 'coins',
                        icon: Icons.remove_circle_outline,
                        iconColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _SummaryCard(
                  title: 'TRANSACTIONS',
                  value: controller.transactionCount.toString(),
                  suffix: '',
                  icon: Icons.swap_horiz,
                  iconColor: Colors.greenAccent,
                ),

                const SizedBox(height: 28),


                _TransactionSectionHeader(
                  selectedFilter: controller.selectedTransactionType.value,
                  showAll: controller.showAllTransactions.value,
                  onFilterSelected: controller.selectTransactionFilter,
                  onViewAllTap: controller.toggleViewAllTransactions,
                ),

                // _SectionTitle(
                //   title: 'TRANSACTION HISTORY',
                //   trailing: 'View All',
                // ),

                const SizedBox(height: 12),

                _TransactionTable(
                  items: controller.visibleWalletHistory,
                ),

                // _TransactionTable(
                //   items: wallet.walletHistory,
                // ),

                const SizedBox(height: 26),

                _HowToEarnCoins(),

                const SizedBox(height: 22),

                _RewardsBenefits(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _topBar() {
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
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Wallet',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track your earnings and transactions',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 38,
          width: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF211F20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none,
            color: AppColors.white,
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int coins;
  final String name;

  const _BalanceCard({
    required this.coins,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF119A72),
            Color(0xFF0D7BC5),
            Color(0xFF23359D),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -70,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -80,
            child: Container(
              height: 145,
              width: 145,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    coins.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 54,
                      height: 0.95,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Coins',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 11,
                    letterSpacing: 1.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 25,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (suffix.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          suffix,
                          style: const TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, color: Colors.greenAccent, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}


class _TransactionSectionHeader extends StatelessWidget {
  final String selectedFilter;
  final bool showAll;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onViewAllTap;

  const _TransactionSectionHeader({
    required this.selectedFilter,
    required this.showAll,
    required this.onFilterSelected,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          color: Colors.greenAccent,
          size: 16,
        ),

        const SizedBox(width: 8),

        const Expanded(
          child: Text(
            'TRANSACTION HISTORY',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),

        PopupMenuButton<String>(
          tooltip: 'Filter transactions',
          color: const Color(0xFF1B1B1B),
          offset: const Offset(0, 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.white.withOpacity(0.10),
            ),
          ),
          onSelected: onFilterSelected,
          itemBuilder: (context) => [
            _filterItem(
              title: 'All',
              value: 'all',
            ),
            _filterItem(
              title: 'Credit',
              value: 'credit',
            ),
            _filterItem(
              title: 'Debit',
              value: 'debit',
            ),
          ],
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: AppColors.white.withOpacity(0.10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.filter_list,
                  color: Colors.greenAccent,
                  size: 18,
                ),

                const SizedBox(width: 5),

                Text(
                  _filterLabel(selectedFilter),
                  style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(width: 2),

                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        GestureDetector(
          onTap: onViewAllTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Text(
              showAll ? 'Show Less' : 'View All',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _filterItem({
    required String title,
    required String value,
  }) {
    final selected = selectedFilter == value;

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
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),

          if (selected)
            const Icon(
              Icons.check,
              color: Colors.greenAccent,
              size: 18,
            ),
        ],
      ),
    );
  }

  String _filterLabel(String value) {
    switch (value) {
      case 'credit':
        return 'Credit';

      case 'debit':
        return 'Debit';

      default:
        return 'All';
    }
  }
}

class _TransactionTable extends StatelessWidget {
  final List<WalletHistoryModel> items;

  const _TransactionTable({
    required this.items,
  });

  String _timeAgo(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return '-';
    }

    final diff = DateTime.now().difference(parsed);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }

    if (diff.inHours > 0) {
      return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
    }

    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min ago';
    }

    return 'Now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                _HeaderCell(
                  'Type',
                  flex: 2,
                ),
                _HeaderCell(
                  'Coins',
                  flex: 2,
                ),
                _HeaderCell(
                  'Message',
                  flex: 4,
                ),
                _HeaderCell(
                  'Date',
                  flex: 2,
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 34,
              ),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...items.map(
                  (item) {
                final isCredit =
                    item.type.trim().toLowerCase() == 'credit';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? Colors.green.withOpacity(0.14)
                                  : Colors.red.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCredit ? 'Credit' : 'Debit',
                              style: TextStyle(
                                color: isCredit
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${isCredit ? '+' : '-'}${item.coins}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isCredit
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: Text(
                            item.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _timeAgo(item.createdAt),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}


class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _HowToEarnCoins extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _BorderSection(
      title: 'HOW TO EARN COINS',
      icon: Icons.monetization_on_outlined,
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: _EarnCard(
                  title: 'Apply for a Job',
                  coins: '20',
                  icon: Icons.work_outline,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _EarnCard(
                  title: 'Complete Assessment',
                  coins: '10',
                  icon: Icons.assignment_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _EarnCard(
            title: 'Attend Interview',
            coins: '50',
            icon: Icons.people_outline,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _EarnCard extends StatelessWidget {
  final String title;
  final String coins;
  final IconData icon;
  final bool fullWidth;

  const _EarnCard({
    required this.title,
    required this.coins,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullWidth ? 92 : 96,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      coins,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Coins',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.white, size: 24),
        ],
      ),
    );
  }
}
class _RewardsBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _BorderSection(
      title: 'REWARDS & BENEFITS',
      child: Column(
        children: const [
          _BenefitCard(
            title: 'Top Performer Bonus',
            subtitle: 'Earn extra 100 coins for being in top 10%',
            icon: Icons.show_chart,
            iconColor: Colors.amber,
          ),
          SizedBox(height: 14),
          _BenefitCard(
            title: 'Referral Program',
            subtitle: 'Refer a friend and earn 200 coins',
            icon: Icons.person_add_alt,
            iconColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}

class _BorderSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const _BorderSection({
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.white, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _BenefitCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


