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


