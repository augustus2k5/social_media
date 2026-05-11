import 'dart:convert';

import 'package:app/features/conversation/data/models/conversation_model.dart';
import 'package:http/http.dart' as http;

class ConversationRemoteDataSource {

  final String baseUrl =
      "http://192.168.75.22:5000/api/conversations";

  Future<List<ConversationModel>> fetchConversations({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (data as List)
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          data["message"] ?? "Failed to fetch conversations",
        );
      }
    } catch (e) {
      print("FETCH CONVERSATIONS ERROR: $e");
      rethrow;
    }
  }
}