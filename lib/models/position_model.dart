class PositionModel {
  final String id;
  final String name;
  final String? shortName;

  PositionModel({
    required this.id,
    required this.name,
    this.shortName,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    final String positionId = (json['_id'] ?? json['id'] ?? '').toString();

    return PositionModel(
      id: positionId,
      name: json['name'] as String? ?? 'Unknown',
      shortName: json['shortName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (shortName != null && shortName!.isNotEmpty) 'shortName': shortName,
      };

  @override
  String toString() => name;
}
