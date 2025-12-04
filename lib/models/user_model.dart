// lib/models/user_model.dart

class UserModel {
  final String? id;
  final String username;
  final String? email;

  /// Club ID assigned from backend
  final String? club;

  /// Club name if backend returns a nested club object
  final String? clubName;

  final String? role;
  final DateTime? createdAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.username,
    this.email,
    this.club,
    this.clubName,
    this.role,
    this.createdAt,
    this.isActive = true,
  });

  /// Safe JSON factory supporting both:
  /// club: "id"
  /// club: { "_id": "...", "name": "..." }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? parsedClubName;
    String? parsedClubId;

    if (json['club'] is Map<String, dynamic>) {
      parsedClubName = json['club']['name'];
      parsedClubId = json['club']['_id'];
    } else if (json['club'] is String) {
      parsedClubId = json['club'];
    }

    return UserModel(
      id: json['_id'] ?? json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      club: parsedClubId,
      clubName: parsedClubName,
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "email": email,
        "club": club,
        "role": role,
        "createdAt": createdAt?.toIso8601String(),
        "isActive": isActive,
      };

  /// Formatted date for UI
  String get createdAtFormatted {
    if (createdAt == null) return "-";
    return "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}";
  }

  /// Easily update user fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? club,
    String? clubName,
    String? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      club: club ?? this.club,
      clubName: clubName ?? this.clubName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// class UserModel {
//   final String? id;
//   final String username;
//   final String? email;
//   final String? club; // club id
//   final String? clubName; // optional for display
//   final String? role;
//   final DateTime? createdAt;
//   final bool? isActive;

//   UserModel({
//     this.id,
//     required this.username,
//     this.email,
//     this.club,
//     this.clubName,
//     this.role,
//     this.createdAt,
//     this.isActive,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     String? clubName;
//     if (json['club'] is Map<String, dynamic>) {
//       clubName = json['club']['name'] as String?;
//     } else if (json['club'] is String) {
//       clubName = null; // only id
//     }

//     return UserModel(
//       id: json['_id'] ?? json['id'],
//       username: json['username'] ?? '',
//       email: json['email'],
//       club: json['club'] is Map ? json['club']['_id'] : json['club'] as String?,
//       clubName: clubName,
//       role: json['role'],
//       createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
//       isActive: json['isActive'] ?? true,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "username": username,
//         "email": email,
//         "club": club,
//         "role": role,
//         "createdAt": createdAt?.toIso8601String(),
//         "isActive": isActive,
//       };

//   String get createdAtFormatted {
//     if (createdAt == null) return '-';
//     return "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}";
//   }

//   UserModel copyWith({
//     String? id,
//     String? username,
//     String? email,
//     String? club,
//     String? role,
//     DateTime? createdAt,
//     bool? isActive,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       username: username ?? this.username,
//       email: email ?? this.email,
//       club: club ?? this.club,
//       clubName: clubName,
//       role: role ?? this.role,
//       createdAt: createdAt ?? this.createdAt,
//       isActive: isActive ?? this.isActive,
//     );
//   }
// }











// class UserModel {
//   final String? id;
//   final String username;
//   final String? email;
//   final String? club;
//   final String? role;
//   final DateTime? createdAt;
//   final bool? isActive;
//   final String? password;

//   UserModel({
//     this.id,
//     required this.username,
//     this.email,
//     this.club,
//     this.role,
//     this.createdAt,
//     this.isActive,
//     this.password,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//         id: json['_id'] ?? json['id'],
//         username: json['username'] ?? '',
//         email: json['email'],
//         club: json['club'],
//         role: json['role'],
//         createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
//         isActive: json['isActive'] ?? true,
//       );

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "username": username,
//         "email": email,
//         "club": club,
//         "role": role,
//         "createdAt": createdAt?.toIso8601String(),
//         "isActive": isActive,
//         if (password != null) "password": password,
//       };

//   // -------------- COPYWITH ----------------
//   UserModel copyWith({
//     String? id,
//     String? username,
//     String? email,
//     String? club,
//     String? role,
//     DateTime? createdAt,
//     bool? isActive,
//     String? password,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       username: username ?? this.username,
//       email: email ?? this.email,
//       club: club ?? this.club,
//       role: role ?? this.role,
//       createdAt: createdAt ?? this.createdAt,
//       isActive: isActive ?? this.isActive,
//       password: password ?? this.password,
//     );
//   }

//   String get createdAtFormatted {
//     if (createdAt == null) return '-';
//     return "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}";
//   }
// }













// import 'package:flutter/material.dart';

// class UserModel {
//   final String id;
//   final String username;
//   final String name;
//   final String? email;
//   final String? club; // Club name or ID
//   final String role;
//   final bool isActive;
//   final DateTime createdAt;

//   UserModel({
//     required this.id,
//     required this.username,
//     required this.name,
//     this.email,
//     this.club,
//     required this.role,
//     required this.isActive,
//     required this.createdAt,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'] ?? json['_id'].toString(),
//       username: json['username'] as String,
//       name: json['name'] as String,
//       email: json['email'] as String?,
//       club: json['club'] as String?,
//       role: json['role'] as String? ?? 'coach',
//       isActive: json['isActive'] as bool? ?? true,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'username': username,
//         'name': name,
//         'email': email,
//         'club': club,
//         'role': role,
//         'isActive': isActive,
//         'createdAt': createdAt.toIso8601String(),
//       };

//   String get roleDisplay => role.toUpperCase();

//   Color get roleColor {
//     switch (role) {
//       case 'admin':
//         return Colors.redAccent;
//       case 'coach':
//         return Colors.blue;
//       case 'player':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   String get clubDisplay => club ?? 'No club';
//   String get activeDisplay => isActive ? 'Active' : 'Inactive';
// }




// import 'package:flutter/material.dart';
// class UserModel {
//   final String id;
//   final String username;
//   final String name;
//   final String? email;
//   final String? club; // Club ID as string (from populated or raw)
//   final String role; // "admin", "coach", "player"
//   final bool isActive;
//   final DateTime createdAt;

//   UserModel({
//     required this.id,
//     required this.username,
//     required this.name,
//     this.email,
//     this.club,
//     required this.role,
//     required this.isActive,
//     required this.createdAt,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'] ?? json['_id'].toString(),
//       username: json['username'] as String,
//       name: json['name'] as String,
//       email: json['email'] as String?,
//       club: json['club'] as String?,
//       role: json['role'] as String? ?? 'coach',
//       isActive: json['isActive'] as bool? ?? true,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//     );
//   }

//   // Optional: for future updates
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'username': username,
//         'name': name,
//         'email': email,
//         'club': club,
//         'role': role,
//         'isActive': isActive,
//         'createdAt': createdAt.toIso8601String(),
//       };

//   // Helper for UI
//   String get roleDisplay => role.toUpperCase();
//   Color get roleColor {
//     switch (role) {
//       case 'admin':
//         return Colors.redAccent;
//       case 'coach':
//         return Colors.blue;
//       case 'player':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }