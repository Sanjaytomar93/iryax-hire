import 'wallet_history_model.dart';

class WalletModel {
  final String candidateId;
  final String name;
  final String email;
  final int totalCoins;
  final List<WalletHistoryModel> walletHistory;

  WalletModel({
    required this.candidateId,
    required this.name,
    required this.email,
    required this.totalCoins,
    required this.walletHistory,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return WalletModel(
      candidateId: data['candidateId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      totalCoins: int.tryParse(data['totalCoins'].toString()) ?? 0,
      walletHistory: (data['walletHistory'] as List? ?? [])
          .map((e) => WalletHistoryModel.fromJson(e))
          .toList(),
    );
  }
}