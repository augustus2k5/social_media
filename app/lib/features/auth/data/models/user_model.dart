import 'package:app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity{


  UserModel({
    required String id,
    required String username,
    required String email,
    required String avatar,
    required String role,
  }) : super(id: id, username: username, email: email, avatar: avatar, role: role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}