import 'package:app/features/chat/domain/entities/message_entity.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> fetchMessages(String conversationId);
  Future<MessageEntity> sendMessage({
    required String receiverId,
    required String content,
  });
}
