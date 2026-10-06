class DashboardCountModel {
  final String name;
  final String email;
  final int openRoles;
  final int applied;
  final int active;
  final int hired;
  final int interviews;

  DashboardCountModel({
    required this.name,
    required this.email,
    required this.openRoles,
    required this.applied,
    required this.active,
    required this.hired,
    required this.interviews,
  });

  factory DashboardCountModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final profile = data['profile'] ?? {};
    final counts = data['counts'] ?? {};

    return DashboardCountModel(
      name: profile['name']?.toString() ?? '',
      email: profile['email']?.toString() ?? '',
      openRoles: int.tryParse(counts['openRoles'].toString()) ?? 0,
      applied: int.tryParse(counts['applied'].toString()) ?? 0,
      active: int.tryParse(counts['active'].toString()) ?? 0,
      hired: int.tryParse(counts['hired'].toString()) ?? 0,
      interviews: int.tryParse(counts['interviews'].toString()) ?? 0,
    );
  }
}