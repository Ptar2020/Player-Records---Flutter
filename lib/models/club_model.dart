import 'player_model.dart';

class ClubModel {
  final String id;
  final String name;
  final String? shortName;
  final String? logo;
  final String? country;
  final String? level;
  final int? playersCount;
  final List<PlayerInClub>? players;

  ClubModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.country,
    this.level,
    this.playersCount,
    this.players,
  });
factory ClubModel.fromJson(Map<String, dynamic> json) {
    // Handle both wrapped { success: true, data: { ... } } and raw document
    Map<String, dynamic> data = json;
    if (json['data'] is Map) {
      data = json['data'] as Map<String, dynamic>;
    } else if (json['success'] == true && json['data'] != null) {
      data = json['data'] as Map<String, dynamic>;
    }

    final String clubId = (data['_id'] ?? data['id'] ?? '').toString();

    final List<dynamic>? playersJson = data['players'];
    final List<PlayerInClub>? playersList = playersJson != null
        ? playersJson
            .map((e) => PlayerInClub.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    return ClubModel(
      id: clubId,
      name: data['name'] as String? ?? 'Unknown Club',
      shortName: data['shortName'] as String?,
      logo: data['logo'] as String?,
      country: data['country'] as String?,
      level: data['level'] as String?,
      playersCount: data['playersCount'] as int? ?? playersList?.length ?? 0,
      players: playersList,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'shortName': shortName,
        'logo': logo,
        'country': country,
        'level': level,
        'playersCount': playersCount,
      };

  @override
  String toString() => name;
}
