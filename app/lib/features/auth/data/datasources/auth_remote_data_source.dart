import 'dart:convert';

import 'package:app/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = "http://192.168.75.22:5000/api/auth";

  Future<(UserModel, String)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        body: jsonEncode({"email": email, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data["user"]);
        final String token = data["token"];

        return (user, token);
      } else {
        throw Exception(data["message"] ?? "Login failed");
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
        headers: {"Content-Type": "application/json"},
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["user"] != null) {
        return UserModel.fromJson(data["user"]);
      } else {
        throw Exception(data["message"] ?? "Register failed");
      }
    } catch (e) {
      print("REGISTER ERROR: $e");
      rethrow;
    }
  }
}
