import 'player.dart';

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

// class Position {
//   final String id;
//   final String name;
//   final String? shortName;

//   Position({
//     required this.id,
//     required this.name,
//     this.shortName,
//   });

//   factory Position.fromJson(Map<String, dynamic> json) => Position(
//         id: json['_id'].toString(),
//         name: json['name'] as String? ?? 'Unknown Position',
//         shortName: json['shortName'] as String?,
//       );
// }

// class ClubModel {
//   final String id;
//   final String name;
//   final String? shortName;
//   final String? logo;
//   final String? country;
//   final String? city;
//   final String? level;
//   final int? playersCount;
//   final List<PlayerInClub>? players;

//   ClubModel({
//     required this.id,
//     required this.name,
//     this.shortName,
//     this.logo,
//     this.country,
//     this.city,
//     this.level,
//     this.playersCount,
//     this.players,
//   });

//   factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
//         id: json['_id']?.toString() ?? json['id'].toString(),
//         name: json['name'] as String? ?? 'Unknown Club',
//         shortName: json['shortName'] as String?,
//         logo: json['logo'] as String?,
//         country: json['country'] as String?,
//         city: json['city'] as String?,
//         level: json['level'] as String?,
//         playersCount: json['playersCount'] as int?,
//         players: json['players'] != null
//             ? (json['players'] as List)
//                 .map((e) => PlayerInClub.fromJson(e as Map<String, dynamic>))
//                 .toList()
//             : null,
//       );
// }

// class PlayerInClub {
//   final String id;
//   final String? name;
//   final String? age;
//   final String? country;
//   final String? photo;
//   final String? phone;
//   final String? email;
//   final String? gender;
//   final Position? position;
//   final ClubModel? club;
//   final int? jerseyNumber;

//   PlayerInClub({
//     required this.id,
//     this.name,
//     this.age,
//     this.country,
//     this.photo,
//     this.position,
//     this.club,
//     this.jerseyNumber,
//     this.phone,
//     this.gender,
//     this.email
//   });

//   factory PlayerInClub.fromJson(Map<String, dynamic> json) {
//     return PlayerInClub(
//       id: json['id']?.toString() ?? json['_id'].toString(),
//       name: json['name'] as String?,
//       age: json['age'] as String?,
//       country: json['country'] as String?,
//       phone: json['phone'] as String?,
//       gender: json['gender'] as String?,
//       email: json['email'] as String?,
//       photo: json['photo'] as String?,
//       jerseyNumber: json['jerseyNumber'] as int?,
//       position: json['position'] != null
//           ? Position.fromJson(json['position'] as Map<String, dynamic>)
//           : null,
//       club: json['club'] != null
//           ? ClubModel.fromJson(json['club'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }