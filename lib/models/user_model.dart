class UserModel {
  final String? id;
  final String username;
  final String name; // <-- REQUIRED (from DB)
  final String? email;
  final String? phone;
  final String? club; // Club ID
  final String? clubName; // when populated
  final String role; // <-- MUST NOT BE NULL
  final DateTime? createdAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.username,
    required this.name,
    this.email,
    this.phone,
    this.club,
    this.clubName,
    required this.role,
    this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? parsedClubId;
    String? parsedClubName;

    if (json["club"] is Map<String, dynamic>) {
      parsedClubId = json["club"]["_id"];
      parsedClubName = json["club"]["name"];
    } else if (json["club"] is String) {
      parsedClubId = json["club"];
    }

    return UserModel(
      id: json["_id"] ?? json["id"],
      username: json["username"] ?? "",
      name: json["name"] ?? "", // from backend
      email: json["email"],
      phone: json["phone"],
      club: parsedClubId,
      clubName: parsedClubName,
      role: json["role"] ?? "coach",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isActive: json["isActive"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "name": name,
        "email": email,
        "phone": phone,
        "club": club,
        "role": role,
        "createdAt": createdAt?.toIso8601String(),
        "isActive": isActive,
      };
}




// class UserModel {
//   final String? id;
//   final String username;
//   final String? email;

//   /// Club ID assigned from backend
//   final String? club;

//   /// Club name if backend returns a nested club object
//   final String? clubName;

//   final String? role;
//   final DateTime? createdAt;
//   final bool isActive;

//   UserModel({
//     this.id,
//     required this.username,
//     this.email,
//     this.club,
//     this.clubName,
//     this.role,
//     this.createdAt,
//     this.isActive = true,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     String? parsedClubName;
//     String? parsedClubId;

//     if (json['club'] is Map<String, dynamic>) {
//       parsedClubName = json['club']['name'];
//       parsedClubId = json['club']['_id'];
//     } else if (json['club'] is String) {
//       parsedClubId = json['club'];
//     }

//     return UserModel(
//       id: json['_id'] ?? json['id'],
//       username: json['username'] ?? '',
//       email: json['email'],
//       club: parsedClubId,
//       clubName: parsedClubName,
//       role: json['role'],
//       createdAt: json['createdAt'] != null
//           ? DateTime.tryParse(json['createdAt'])
//           : null,
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

//   /// Formatted date for UI
//   String get createdAtFormatted {
//     if (createdAt == null) return "-";
//     return "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}";
//   }

//   /// Easily update user fields
//   UserModel copyWith({
//     String? id,
//     String? username,
//     String? email,
//     String? club,
//     String? clubName,
//     String? role,
//     DateTime? createdAt,
//     bool? isActive,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       username: username ?? this.username,
//       email: email ?? this.email,
//       club: club ?? this.club,
//       clubName: clubName ?? this.clubName,
//       role: role ?? this.role,
//       createdAt: createdAt ?? this.createdAt,
//       isActive: isActive ?? this.isActive,
//     );
//   }
// }
