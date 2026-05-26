import 'dart:convert';

import 'package:app/features/chat/data/models/message_model.dart';
import 'package:http/http.dart' as http;

class MessageRemoteDataSource {
  final String baseUrl = "http://192.168.75.22:5000/api/messages";
    // final String baseUrl = "http://172.16.0.151:5000/api/messages";

  Future<List<MessageModel>> fetchMessages({
    required String token,
    required String conversationId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$conversationId"),

        headers: {
          "Content-Type": "application/json",

          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (data as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();
      } else {
        throw Exception(data["message"] ?? "Failed to fetch messages");
      }
    } catch (e) {
      print("FETCH MESSAGES ERROR: $e");

      rethrow;
    }
  }

  Future<MessageModel> sendMessage({
    required String token,
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),

        headers: {
          "Content-Type": "application/json",

          "Authorization": "Bearer $token",
        },

        body: jsonEncode({"receiverId": receiverId, "content": content}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return MessageModel.fromJson(data);
      } else {
        throw Exception(data["message"] ?? "Failed to send message");
      }
    } catch (e) {
      print("SEND MESSAGE ERROR: $e");

      rethrow;
    }
  }
}
