import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../model/wallet_history_model.dart';
import '../model/wallet_model.dart';
import '../services/profile_service.dart';
import 'profile_controller.dart';

class WalletController extends GetxController {
  final ProfileService profileService;

  WalletController(this.profileService);

  final isLoading = false.obs;
  final wallet = Rxn<WalletModel>();

  final selectedTransactionType = 'all'.obs;
  final showAllTransactions = false.obs;

  int get totalCoins => wallet.value?.totalCoins ?? 0;

  int get totalEarned {
    return wallet.value?.walletHistory
        .where(
          (item) => item.type.toLowerCase() == 'credit',
    )
        .fold<int>(
      0,
          (sum, item) => sum + item.coins,
    ) ??
        0;
  }

  int get totalSpent {
    return wallet.value?.walletHistory
        .where(
          (item) => item.type.toLowerCase() == 'debit',
    )
        .fold<int>(
      0,
          (sum, item) => sum + item.coins,
    ) ??
        0;
  }

  int get transactionCount {
    return wallet.value?.walletHistory.length ?? 0;
  }

  List<WalletHistoryModel> get filteredWalletHistory {
    final history = wallet.value?.walletHistory ?? [];

    switch (selectedTransactionType.value) {
      case 'credit':
        return history
            .where(
              (item) => item.type.toLowerCase() == 'credit',
        )
            .toList();

      case 'debit':
        return history
            .where(
              (item) => item.type.toLowerCase() == 'debit',
        )
            .toList();

      default:
        return history;
    }
  }

  List<WalletHistoryModel> get visibleWalletHistory {
    final history = filteredWalletHistory;

    if (showAllTransactions.value) {
      return history;
    }

    return history.take(5).toList();
  }

  String get selectedFilterLabel {
    switch (selectedTransactionType.value) {
      case 'credit':
        return 'Credit';

      case 'debit':
        return 'Debit';

      default:
        return 'All';
    }
  }

  @override
  void onReady() {
    super.onReady();
    getWallet();
  }

  Future<void> getWallet() async {
    try {
      isLoading.value = true;

      String candidateId = '';

      if (Get.isRegistered<ProfileController>()) {
        final profileController =
        Get.find<ProfileController>();

        if (profileController.candidateId.value.isEmpty) {
          await profileController.getProfile();
        }

        candidateId =
            profileController.candidateId.value.trim();
      }

      if (candidateId.isEmpty) {
        final candidate = StorageService.getCandidate();

        candidateId =
            candidate?['_id']?.toString() ??
                candidate?['id']?.toString() ??
                '';
      }

      if (candidateId.isEmpty) {
        Get.snackbar(
          'Error',
          'Candidate ID missing',
        );
        return;
      }

      final token = StorageService.getToken();

      if (token.isEmpty) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
        );
        return;
      }

      final response =
      await profileService.getCandidateWallet(
        token: token,
        candidateId: candidateId,
      );

      debugPrint(
        '🟢 WALLET RESPONSE: ${response.data}',
      );

      wallet.value = WalletModel.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );

      selectedTransactionType.value = 'all';
      showAllTransactions.value = false;
    } catch (e) {
      debugPrint(
        '🔴 WALLET ERROR: $e',
      );

      Get.snackbar(
        'Error',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshWallet() async {
    await getWallet();
  }

  void selectTransactionFilter(
      String value,
      ) {
    selectedTransactionType.value = value;
    showAllTransactions.value = false;
  }

  void toggleViewAllTransactions() {
    showAllTransactions.value =
    !showAllTransactions.value;
  }

  void resetTransactionFilter() {
    selectedTransactionType.value = 'all';
    showAllTransactions.value = false;
  }
}