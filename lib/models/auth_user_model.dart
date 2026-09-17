enum UserRole {
  guest,
  member,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.member:
        return 'Registered Member';
      case UserRole.guest:
        return 'Guest';
    }
  }
}

class AuthUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final UserRole role;
  final String? memberUserId;
  final String? phone;
  final String? status;
  final String? token;
  final Map<String, dynamic>? rawData;

  const AuthUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.memberUserId,
    this.phone,
    this.status,
    this.token,
    this.rawData,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;

  factory AuthUser.fromJson(Map<String, dynamic> json, UserRole role) {
    String parsedName = 'User';
    if (json['name'] != null && json['name'].toString().isNotEmpty) {
      parsedName = json['name'].toString();
    } else if (json['first_name'] != null) {
      parsedName = '${json['first_name']} ${json['last_name'] ?? ''}'.trim();
    } else if (json['username'] != null) {
      parsedName = json['username'].toString();
    }

    return AuthUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['user_id']?.toString() ?? '',
      name: parsedName,
      email: json['email']?.toString() ?? '',
      role: role,
      memberUserId: json['user_id']?.toString() ?? json['member_id']?.toString(),
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      token: json['token']?.toString(),
      rawData: json,
    );
  }

  AuthUser copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    UserRole? role,
    String? memberUserId,
    String? phone,
    String? status,
    String? token,
    Map<String, dynamic>? rawData,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      memberUserId: memberUserId ?? this.memberUserId,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      token: token ?? this.token,
      rawData: rawData ?? this.rawData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role.name,
      'memberUserId': memberUserId,
      'phone': phone,
      'status': status,
      'token': token,
    };
  }
}
