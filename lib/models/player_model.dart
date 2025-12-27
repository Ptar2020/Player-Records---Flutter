import 'club_model.dart';

class Player {
  final String id;
  final String name;
  final int? age;
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
    this.age,
    required this.country,
    this.photo,
    this.position,
    this.club,
    this.phone,
    this.email,
    this.gender,
    this.jerseyNumber,
  });

  factory Player.fromPlayerInClub(PlayerInClub p) {
    return Player(
      id: p.id,
      name: p.name?.trim().isNotEmpty == true ? p.name! : " Player",
      age: p.age != null ? int.tryParse(p.age!) : null,
      country: p.country?.trim().isNotEmpty == true ? p.country! : "Unknown",
      photo: p.photo?.trim().isNotEmpty == true ? p.photo!.trim() : null,
      position: p.position,
      club: p.club,
      phone: p.phone?.trim().isNotEmpty == true ? p.phone!.trim() : null,
      email: p.email?.trim().isNotEmpty == true ? p.email!.trim() : null,
      gender: p.gender,
      jerseyNumber: p.jerseyNumber,
    );
  }

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    return parts.map((e) => e[0]).take(2).join().toUpperCase();
  }
}

class Position {
  final String id;
  final String name;
  final String? shortName;

  Position({
    required this.id,
    required this.name,
    this.shortName,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['_id'];
    final String positionId = idRaw?.toString() ?? '';

    return Position(
      id: positionId,
      name: json['name'] as String? ?? 'Unknown Position',
      shortName: json['shortName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
      };
}

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
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] as String?,
      age: json['age'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      email: json['email'] as String?,
      photo: json['photo'] as String?,
      jerseyNumber: json['jerseyNumber'] is int
          ? json['jerseyNumber'] as int
          : (json['jerseyNumber'] is String
              ? int.tryParse(json['jerseyNumber'])
              : null),
      position: json['position'] != null
          ? Position.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      club: json['club'] != null
          ? ClubModel.fromJson(json['club'] as Map<String, dynamic>)
          : null,
    );
  }
}
