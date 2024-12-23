import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../pages/chat_page.dart'; // Import the ChatPage widget

class ChatListPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ChatListPage({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to new chat screen
            },
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(""" 
            query {
              getAllUserEmails
            }
          """),
          pollInterval: const Duration(seconds: 5),
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final List<String> emails = List<String>.from(result.data?['getAllUserEmails'] ?? []);

          // Filter out current user's email
          emails.removeWhere((email) => email == userData?['email']);

          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/7.x/avataaars/png?seed=$email',
                  ),
                ),
                title: Text(email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        userData: {
                          ...?userData,
                          'recipientEmail': email,
                          'recipientName': email,
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
