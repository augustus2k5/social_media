import 'package:app/core/theme.dart';
import 'package:app/features/auth/data/datasources/token_service.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/chat/presentation/pages/chat_page.dart';
import 'package:app/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:app/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:app/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app/features/auth/presentation/bloc/auth_event.dart';

class ConversationsPage extends StatefulWidget {
  ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final conversationRepository = ConversationRepositoryImpl(
    remoteDataSource: ConversationRemoteDataSource(),

    tokenService: TokenService(),
  );
  final ContactRemoteDataSource _contactDataSource = ContactRemoteDataSource();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationBloc>(context).add(FetchConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages", style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, size: 28),
            color: DefaultColors.messageListPage,
            onSelected: (value) {
              if (value == "account") {
                // TODO: Navigate to My Account page
              } else if (value == "logout") {
                context.read<AuthBloc>().add(LogoutEvent());

                Navigator.pushNamedAndRemoveUntil(
                  context,

                  "/login",

                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "account",
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 10),
                    Text("My Account", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Logout", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            padding: EdgeInsets.all(5),

            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
                _buildRecentContact("Kaori", context),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DefaultColors.messageListPage,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
              ),
              child: BlocBuilder<ConversationBloc, ConversationState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ConversationsLoaded) {
                    if (state.conversations.isEmpty) {
                      return Center(child: Text("No conversations found"));
                    }

                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];

                        final vietnamTime = conversation.lastMessageTime
                            ?.toLocal();

                        final formattedTime = vietnamTime != null
                            ? DateFormat(
                                "yyyy-MM-dd hh:mm a",
                              ).format(vietnamTime)
                            : "";
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  conversationId: conversation.id,
                                  receiverId: conversation.user.id,
                                  receiverName: conversation.user.username,
                                ),
                              ),
                            );
                          },
                          child: _buildMessageTile(
                            conversation.user.username,
                            conversation.lastMessage,
                            formattedTime,
                          ),
                        );
                      },
                    );
                  } else if (state is ConversationsError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text("No conversations found"));
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          showDialog(
            context: context,

            builder: (_) {
              return AlertDialog(
                title: const Text("Search user"),

                content: TextField(
                  controller: _searchController,

                  decoration: const InputDecoration(hintText: "Enter email"),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text("Cancel"),
                  ),

                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await _searchUser();
                    },

                    child: const Text("Search"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _searchUser() async {
    try {
      final user = await _contactDataSource.searchUserByEmail(
        _searchController.text.trim(),
      );

      final conversationId = await conversationRepository.createConversation(
        user.id,
      );

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversationId,

            receiverId: user.id,

            receiverName: user.username,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

Widget _buildMessageTile(String name, String message, String time) {
  return ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    leading: CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvr2yIZtFjP-k3bqrpHNrrQMBIFQhjLsYaRA&s",
      ),
    ),
    title: Text(
      name,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(
      message,
      style: TextStyle(color: Colors.grey),
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Text(time, style: TextStyle(color: Colors.grey)),
  );
}

Widget _buildRecentContact(String name, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvr2yIZtFjP-k3bqrpHNrrQMBIFQhjLsYaRA&s",
          ),
        ),
        SizedBox(height: 5),
        Text(name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
