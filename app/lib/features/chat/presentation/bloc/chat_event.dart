abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String conversationId;

  LoadMessagesEvent(this.conversationId);
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;

  final String receiverId;

  final String content;

  SendMessageEvent({
    required this.conversationId,

    required this.receiverId,

    required this.content,
  });
}

class ReceiveMessageEvent extends ChatEvent {
  final Map<String, dynamic> message;

  ReceiveMessageEvent(this.message);
}
