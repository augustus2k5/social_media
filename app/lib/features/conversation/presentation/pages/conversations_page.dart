import 'package:app/core/theme.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
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
          IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 30)),
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
                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return _buildMessageTile(conversation.user.username, conversation.lastMessage, conversation.lastMessageTime.toString());
                      },
                    );
                  } else if(state is ConversationsError) {
                    return Center(child: Text(state.message),);
                  }
                  return Center(child: Text("No conversations found"),);
                },
              ),
            ),
          ),
        ],
      ),
    );
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
