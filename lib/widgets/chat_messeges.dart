import 'package:chat/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMesseges extends StatelessWidget {
  const ChatMesseges({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (chatSnapshot.hasError) {
          const Center(
            child: Text('Something went wrong.'),
          );
        }

        final loadedMesseges = chatSnapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMesseges.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMesseges[index].data();
            final nextChatMessage = index + 1 < loadedMesseges.length
                ? loadedMesseges[index + 1].data()
                : null;
            final currentMessageUsernameId = chatMessage['user'];
            final nextMessageUsernameId =
                nextChatMessage != null ? nextChatMessage['user'] : null;
            final nextUserIsSame =
                nextMessageUsernameId == currentMessageUsernameId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser!.uid == currentMessageUsernameId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser!.uid == currentMessageUsernameId,
              );
            }
          },
        );
      },
    );
  }
}
