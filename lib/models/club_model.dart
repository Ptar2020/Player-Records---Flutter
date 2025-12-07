import 'player_model.dart';

class ClubModel {
  final String id;
  final String name;
  final String? shortName;
  final String? logo;
  final String? country;
  final String? city;
  final String? level;
  final int? playersCount;
  final List<PlayerInClub>? players;

  ClubModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.country,
    this.city,
    this.level,
    this.playersCount,
    this.players,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
        id: (json['_id'] ?? json['id']).toString(),
        name: json['name'] as String? ?? 'Unknown Club',
        shortName: json['shortName'] as String?,
        logo: json['logo'] as String?,
        country: json['country'] as String?,
        city: json['city'] as String?,
        level: json['level'] as String?,
        playersCount: json['playersCount'] is int ? json['playersCount'] as int : (json['playersCount'] is String ? int.tryParse(json['playersCount']) : null),
        players: json['players'] != null
            ? (json['players'] as List).map((e) => PlayerInClub.fromJson(e as Map<String, dynamic>)).toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'shortName': shortName,
        'logo': logo,
        'country': country,
        'city': city,
        'level': level,
        'playersCount': playersCount,
        'players': players?.map((p) => p.id).toList(),
      };
}
