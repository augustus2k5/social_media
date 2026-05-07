import 'package:app/features/auth/domain/entities/user_entity.dart';

class ConversationEntity {
  final String id;
  final UserEntity user;
  final String lastMessage;
  final DateTime? lastMessageTime;

  ConversationEntity({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}