import 'package:app/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {

  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return MessageModel(

      id: json['_id'],

      conversationId:
          json['conversationId'],

      senderId:
          json['senderId'],

      content:
          json['content'] ?? '',

      isRead:
          json['isRead'] ?? false,

      createdAt:
          DateTime.parse(
            json['createdAt'],
          ),

      updatedAt:
          DateTime.parse(
            json['updatedAt'],
          ),
    );
  }
}