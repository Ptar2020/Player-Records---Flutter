// lib/models/player.dart
import 'package:flutter/foundation.dart';
import 'club_model.dart';

class Player {
  final String id;
  final String name;
  final String age;
  final String country;
  final String? photo;
  final Position? position;
  final ClubModel? club;
  final String? phone;
  final String? email;
  final String? gender;
  final int? jerseyNumber;

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.country,
    this.photo,
    this.position,
    this.club,
    this.phone,
    this.email,
    this.gender,
    this.jerseyNumber,
  });

  factory Player.fromPlayerInClub(PlayerInClub p, {ClubModel? club}) {
    return Player(
      id: p.id,
      name: (p.name?.trim().isNotEmpty == true) ? p.name! : "Unknown Player",
      age: (p.age?.trim().isNotEmpty == true) ? p.age! : "??",
      country: (p.country?.trim().isNotEmpty == true) ? p.country! : "Unknown",
      photo: (p.photo?.trim().isNotEmpty == true) ? p.photo!.trim() : null,
      position: p.position,
      club: p.club ?? club,
      phone: p.phone,
      email: p.email,
      gender: p.gender,
      jerseyNumber: p.jerseyNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'country': country,
        'photo': photo,
        'position': position?.toJson(),
        'club': club?.toJson(),
        'phone': phone,
        'email': email,
        'gender': gender,
        'jerseyNumber': jerseyNumber,
      };

  // helper for initials (cached by caller if needed)
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    final extracted = parts.map((e) => e[0]).take(2).join().toUpperCase();
    return extracted;
  }
}

// Position model (used by Player & PlayerInClub)
class Position {
  final String id;
  final String name;
  final String? shortName;

  Position({
    required this.id,
    required this.name,
    this.shortName,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        id: json['_id']?.toString() ?? json['id'].toString(),
        name: json['name'] as String? ?? 'Unknown Position',
        shortName: json['shortName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'shortName': shortName,
      };
}

// DTO as returned by API (Player inside club list)
class PlayerInClub {
  final String id;
  final String? name;
  final String? age;
  final String? country;
  final String? photo;
  final String? phone;
  final String? email;
  final String? gender;
  final Position? position;
  final ClubModel? club;
  final int? jerseyNumber;

  PlayerInClub({
    required this.id,
    this.name,
    this.age,
    this.country,
    this.photo,
    this.position,
    this.club,
    this.jerseyNumber,
    this.phone,
    this.gender,
    this.email,
  });

  factory PlayerInClub.fromJson(Map<String, dynamic> json) {
    return PlayerInClub(
      id: (json['id'] ?? json['_id']).toString(),
      name: json['name'] as String?,
      age: json['age'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      email: json['email'] as String?,
      photo: json['photo'] as String?,
      jerseyNumber: json['jerseyNumber'] is int
          ? json['jerseyNumber'] as int
          : (json['jerseyNumber'] is String ? int.tryParse(json['jerseyNumber']) : null),
      position: json['position'] != null ? Position.fromJson(json['position'] as Map<String, dynamic>) : null,
      club: json['club'] != null ? ClubModel.fromJson(json['club'] as Map<String, dynamic>) : null,
    );
  }
}

// import 'club_model.dart';

// class Player {
//   final String id;
//   final String name;
//   final String age;
//   final String country;
//   final String? photo;
//   final Position? position;
//   final ClubModel? club;
//   final String? phone;
//   final String? email;
//   final String? gender;
//   final int? jerseyNumber;        // ← THIS WAS MISSING!

//   Player({
//     required this.id,
//     required this.name,
//     required this.age,
//     required this.country,
//     this.photo,
//     this.position,
//     this.club,
//     this.phone,
//     this.email,
//     this.gender,
//     this.jerseyNumber,             // ← ADD THIS
//   });

//   factory Player.fromPlayerInClub(PlayerInClub p, {ClubModel? club}) {
//     return Player(
//       id: p.id,
//       name: p.name?.trim().isNotEmpty == true ? p.name! : "Unknown Player",
//       age: p.age?.trim().isNotEmpty == true ? p.age! : "??",
//       country: p.country?.trim().isNotEmpty == true ? p.country! : "Unknown",
//       photo: p.photo?.trim().isNotEmpty == true ? p.photo!.trim() : null,
//       position: p.position,
//       club: p.club ?? club,
//       phone: null,
//       email: null,
//       gender: null,
//       jerseyNumber: p.jerseyNumber,   // ← PASS IT THROUGH
//     );
//   }
// }










// import 'club_model.dart';

// class Player {
//   final String id;
//   final String name;
//   final String age;
//   final String country;
//   final String? photo;
//   final Position? position;
//   final ClubModel? club;
//   final String? phone;
//   final String? email;
//   final String? gender;



//   Player({
//     required this.id,
//     required this.name,
//     required this.age,
//     required this.country,
//     this.photo,
//     this.position,
//     this.club,
//     this.phone,    
//     this.email,
//     this.gender

//   });

//   factory Player.fromPlayerInClub(PlayerInClub p, {ClubModel? club}) {
//     return Player(
//       id: p.id,
//       name: p.name?.trim().isNotEmpty == true ? p.name! : "Unknown Player",
//       age: p.age?.trim().isNotEmpty == true ? p.age! : "??",
//       country: p.country?.trim().isNotEmpty == true ? p.country! : "Unknown",
//       photo: p.photo?.trim().isNotEmpty == true ? p.photo!.trim() : null,
//       position: p.position,
//       club: p.club, 
//       gender: p.gender?.trim().isNotEmpty == true ? p.gender!.trim() : null,
//       phone: p.phone?.trim().isNotEmpty == true ? p.phone!.trim() : null,
//       email: p.email?.trim().isNotEmpty == true ? p.email!.trim() : null,

//     );
//   }
// }