import 'package:app/core/theme.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvr2yIZtFjP-k3bqrpHNrrQMBIFQhjLsYaRA&s",
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Miyamoto Mushashi",
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
          IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 30)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildReceivedMessage(context, "Can i ask you something?"),
                _buildSentMessage(context, "For sure"),
              ],
            ),
          ),
          _buildMessageInput()
        ],
      ),
    );
  }
}

Widget _buildReceivedMessage(BuildContext context, String message) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(right: 30, top: 5, bottom: 5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DefaultColors.receiverMessage,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(20),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    ),
  );
}

Widget _buildSentMessage(BuildContext context, String message) {
  return Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: EdgeInsets.only(right: 30, top: 5, bottom: 5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DefaultColors.senderMessage,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}


Widget _buildMessageInput() {
  return Container(
    decoration: BoxDecoration(
      color: DefaultColors.sentMessageInput,
      borderRadius: BorderRadius.circular(25)
    ),
    margin: EdgeInsets.only(bottom: 60, top: 25, left: 25, right: 25),
    padding: EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: [
        GestureDetector(
          child: Icon(Icons.camera_alt, color: Colors.grey,),
          onTap: () {
            
          },

        ),
        SizedBox(width: 10,),
        Expanded(child: TextField(
          decoration: InputDecoration(
            hintText: "Message",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none
          ),
          style: TextStyle(color: Colors.white),
        )),
        SizedBox(width: 10,),
        GestureDetector(
          child: Icon(Icons.send, color: Colors.grey,),
          onTap: () {
            
          },
        )
        
      ],
    ),
  );
}