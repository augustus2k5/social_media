import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required super.id,
    required super.user,
    required super.lastMessage,
    required super.lastMessageTime,
  });

  factory ConversationModel.fromJson(
  Map<String, dynamic> json,
) {

  final userJson = json['user'];

  userJson['id'] = userJson['_id'];

  return ConversationModel(
    id: json['conversationId'],

    user: UserModel.fromJson(userJson),

    lastMessage:
        json['lastMessage'] ?? '',

    lastMessageTime:
        json['lastMessageTime'] != null
            ? DateTime.parse(
                json['lastMessageTime'],
              )
            : null,
  );
}
}