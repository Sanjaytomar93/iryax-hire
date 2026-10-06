class WalletHistoryModel {
  final String id;
  final int coins;
  final String type;
  final String message;
  final String createdAt;

  WalletHistoryModel({
    required this.id,
    required this.coins,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      id: json['_id']?.toString() ?? '',
      coins: int.tryParse(json['coins'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}