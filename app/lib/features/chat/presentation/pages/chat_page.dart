import 'package:app/core/theme.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/chat/presentation/bloc/chat_event.dart';
import 'package:app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_event.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String currentUserId = "";

  @override
  void initState() {
    super.initState();

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _fetchUserId();

    if (!mounted) {
      return;
    }

    context.read<ChatBloc>().add(LoadMessagesEvent(widget.conversationId));
  }

  Future<void> _fetchUserId() async {
    final userId = await _storage.read(key: "userId") ?? "";

    setState(() {
      currentUserId = userId;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();

    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();

    if (content.isEmpty) {
      return;
    }

    context.read<ChatBloc>().add(
      SendMessageEvent(
        conversationId: widget.conversationId,

        receiverId: widget.receiverId,

        content: content,
      ),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 25,

              backgroundImage: NetworkImage(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvr2yIZtFjP-k3bqrpHNrrQMBIFQhjLsYaRA&s",
              ),
            ),

            const SizedBox(width: 10),

            Text(
              widget.receiverName,

              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: DefaultColors.greyText),
            ),
          ],
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,

        toolbarHeight: 70,

        actions: [
          IconButton(
            onPressed: () {},

            icon: const Icon(Icons.search, size: 30),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessageSentState) {
                  context.read<ConversationBloc>().add(
                    FetchConversations(),
                  );
                }
              },

              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatErrorState) {
                  return Center(child: Text(state.message));
                }

                if (state is ChatLoadedState || state is MessageSentState) {
                  final messages = state is ChatLoadedState
                      ? state.messages
                      : (state as MessageSentState).messages;

                  if (messages.isEmpty) {
                    return const Center(child: Text("No messages yet"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),

                    itemCount: messages.length,

                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isMe = message.senderId == currentUserId;

                      if (isMe) {
                        return _buildSentMessage(context, message);
                      }

                      return _buildReceivedMessage(context, message);
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context, MessageEntity message) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.only(right: 30, top: 5, bottom: 5),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: DefaultColors.receiverMessage,

          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),

            bottomLeft: Radius.circular(20),

            topRight: Radius.circular(15),

            bottomRight: Radius.circular(15),
          ),
        ),

        child: Text(
          message.content,

          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, MessageEntity message) {
    return Align(
      alignment: Alignment.centerRight,

      child: Container(
        margin: const EdgeInsets.only(left: 30, top: 5, bottom: 5),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: DefaultColors.senderMessage,

          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),

            bottomLeft: Radius.circular(15),

            topRight: Radius.circular(5),

            bottomRight: Radius.circular(20),
          ),
        ),

        child: Text(
          message.content,

          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,

        borderRadius: BorderRadius.circular(25),
      ),

      margin: const EdgeInsets.only(bottom: 60, top: 25, left: 25, right: 25),

      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {},

            child: const Icon(Icons.camera_alt, color: Colors.grey),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: _messageController,

              decoration: const InputDecoration(
                hintText: "Message",

                hintStyle: TextStyle(color: Colors.grey),

                border: InputBorder.none,
              ),

              style: const TextStyle(color: Colors.white),

              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: _sendMessage,

            child: const Icon(Icons.send, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
