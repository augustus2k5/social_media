class MessageEntity {
  final String id;

  final String conversationId;

  final String senderId;

  final String content;

  final bool isRead;

  final DateTime createdAt;

  final DateTime updatedAt;

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });
}