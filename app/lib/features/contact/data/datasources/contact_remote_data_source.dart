import 'dart:convert';

import 'package:app/features/auth/data/datasources/token_service.dart';

import 'package:app/features/auth/data/models/user_model.dart';

import 'package:http/http.dart' as http;

class ContactRemoteDataSource {
  final String baseUrl = "http://192.168.75.22:5000/api/contacts";
  // final String baseUrl = "http://172.16.0.151:5000/api/contacts";

  final TokenService tokenService = TokenService();

  Future<UserModel> searchUserByEmail(String email) async {
    final token = await tokenService.getToken();

    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/search?email=$email"),

      headers: {
        "Authorization": "Bearer $token",

        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print(data);
      return UserModel.fromJson({
        "id": data["_id"],

        "username": data["username"],

        "email": data["email"],

        "avatar": data["avatar"],

        "role": data["role"],
      });
    }

    throw Exception(data["message"]);
  }

  Future<String> createConversation({
    required String token,

    required String receiverId,
  }) async {
    final response = await http.post(
      Uri.parse("http://192.168.75.22:5000/api/conversations"),

      headers: {
        "Content-Type": "application/json",

        "Authorization": "Bearer $token",
      },

      body: jsonEncode({"receiverId": receiverId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data["_id"];
    }

    throw Exception(data["message"]);
  }
}
