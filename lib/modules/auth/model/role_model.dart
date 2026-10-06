class RoleModel {
  final String id;
  final String name;
  final String description;

  const RoleModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
    );
  }
}