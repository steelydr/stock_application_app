import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../pages/home_page.dart';
import '../widgets/chat_list_page.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ChatPage({Key? key, this.userData}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Logger logger = Logger();
  bool _isComposing = false;

  String get _userEmail => widget.userData?['email'] ?? 'User';
  String get _recipientEmail => widget.userData?['recipientEmail'] ?? '';

  // GraphQL queries remain the same
  final String fetchChatsQuery = """
    query GetChatsByParticipants(\$senderEmail: String!, \$recipientEmail: String!) {
      getChatsByParticipants(senderEmail: \$senderEmail, recipientEmail: \$recipientEmail) {
        senderEmail
        recipientEmail
        message
        timestamp
      }
    }
  """;

  final String sendMessageMutation = """
    mutation SendMessage(\$senderEmail: String!, \$recipientEmail: String!, \$message: String!, \$isAI: Boolean!) {
      sendMessage(senderEmail: \$senderEmail, recipientEmail: \$recipientEmail, message: \$message, isAI: \$isAI)
    }
  """;

  Widget _buildMessageBubble(Map<String, dynamic> chat, bool isSender) {
    final message = chat['message'] as String;
    final timestamp = DateTime.parse(chat['timestamp'] ?? DateTime.now().toIso8601String());
    final time = DateFormat('HH:mm').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${chat['senderEmail']}'),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: isSender
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSender ? 20 : 5),
                  bottomRight: Radius.circular(isSender ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isSender ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSender ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$_userEmail'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(RunMutation runMutation) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onChanged: (text) {
                            setState(() {
                              _isComposing = text.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          style: const TextStyle(fontSize: 16),
                          maxLines: null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        color: Colors.grey[600],
                        onPressed: () {
                          // Implement file attachment
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: _isComposing ? Theme.of(context).primaryColor : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(_isComposing ? Icons.send : Icons.mic),
                  color: _isComposing ? Colors.white : Colors.grey[600],
                  onPressed: _isComposing
                      ? () {
                    runMutation({
                      'senderEmail': _userEmail,
                      'recipientEmail': _recipientEmail,
                      'message': _messageController.text,
                      'isAI': false,
                    });
                    _messageController.clear();
                    setState(() {
                      _isComposing = false;
                    });
                  }
                      : () {
                    // Implement voice message
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blue,
                Colors.purpleAccent,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$_recipientEmail'),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recipientEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.white),
            onPressed: () {
              // Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // Implement voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Implement more options
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.blue,
              Colors.purpleAccent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
          ],
          currentIndex: 1, // Since we're on the chat page
          onTap: (index) {
            if (index == 0) {
              // Navigate to HomePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else if (index == 1) {
              // Navigate to ChatListPage with userData
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListPage(userData: widget.userData)),
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(fetchChatsQuery),
                variables: {
                  'senderEmail': _userEmail,
                  'recipientEmail': _recipientEmail,
                },
                pollInterval: const Duration(seconds: 5),
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.hasException) {
                  return Center(
                    child: Text(
                      'Error: ${result.exception.toString()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final List chats = result.data?['getChatsByParticipants'] ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isSender = chat['senderEmail'] == _userEmail;
                    return _buildMessageBubble(chat, isSender);
                  },
                );
              },
            ),
          ),
          Mutation(
            options: MutationOptions(
              document: gql(sendMessageMutation),
              onCompleted: (dynamic resultData) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return _buildInputArea(runMutation);
            },
          ),
        ],
      ),
    );
  }
}
