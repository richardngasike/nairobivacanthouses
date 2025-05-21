import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  final List<Map<String, String>> messages = [
    {
      'name': 'CEO Richard Ngasike',
      'message': 'To post your vacant whatsapp 0718959781...',
      'time': '2 days ago',
      'image': 'assets/images/richard.png',
    },
    {
      'name': 'NVH Office Assistant',
      'message': 'website doesnt support posting, purchase our app..',
      'time': '10:30 AM',
      'image': 'assets/images/assistance.jpeg',
    },
    {
      'name': 'NVH Secretary',
      'message': 'Whatsapp our official number...',
      'time': 'Yesterday',
      'image': 'assets/images/secretary.jpeg',
    },
  ];

  MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Dear user, please WhatsApp 0718959781 to post vacants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipOval(
                      child: Image.asset(
                        messages[index]['image']!,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                size: 30, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      messages[index]['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(messages[index]['message']!),
                    trailing: Text(
                      messages[index]['time']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            contactName: messages[index]['name']!,
                            contactImage: messages[index]['image']!,
                            initialMessage: messages[index]['message']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactImage;
  final String initialMessage;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.contactImage,
    required this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    // Add the initial message from the contact
    messages.add({
      'text': widget.initialMessage,
      'isMe': 'false',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'text': _messageController.text,
          'isMe': 'true',
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                widget.contactImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, size: 20, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.contactName),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isMe = messages[index]['isMe'] == 'true';
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.orange[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(messages[index]['text']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message... (use keyboard for emojis)',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MessagesPage(),
  ));
}
