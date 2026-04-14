import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Map<String, dynamic>? _userData;
  
  final List<Map<String, dynamic>> _messages = [
    {
      'name': 'Tech Innovators Inc.',
      'lastMessage': 'Hi! We reviewed your application for Senior Flutter Developer...',
      'time': '10:30 AM',
      'unread': true,
      'isEmployer': true,
      'imageIndex': 1,
      'jobTitle': 'Senior Flutter Developer',
    },
    {
      'name': 'Creative Solutions',
      'lastMessage': 'When are you available for the UI/UX Designer interview?',
      'time': 'Yesterday',
      'unread': false,
      'isEmployer': true,
      'imageIndex': 2,
      'jobTitle': 'UI/UX Designer',
    },
    {
      'name': 'John Smith',
      'lastMessage': 'Thanks for applying! We\'ll get back to you soon...',
      'time': '2 days ago',
      'unread': true,
      'isEmployer': false,
      'imageIndex': 3,
      'jobTitle': 'Backend Developer',
    },
    {
      'name': 'Cloud Systems Ltd.',
      'lastMessage': 'Your interview is scheduled for Friday at 2:00 PM',
      'time': '3 days ago',
      'unread': false,
      'isEmployer': true,
      'imageIndex': 4,
      'jobTitle': 'DevOps Engineer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userId = prefs.getInt('user_id');
      final fullname = prefs.getString('user_fullname');
      final email = prefs.getString('user_email');
      final username = prefs.getString('user_username');
      final isVerified = prefs.getBool('is_verified') ?? false;
      final isLoggedIn = prefs.getBool('is_logged_in');
      
      // Print session for debugging
      print('\n========== MESSAGE PAGE - USER SESSION ==========');
      print('Is Logged In: $isLoggedIn');
      print('User ID: $userId');
      print('Full Name: $fullname');
      print('Username: $username');
      print('Email: $email');
      print('Is Verified: $isVerified');
      print('Total Conversations: ${_messages.length}');
      print('Unread: ${_messages.where((m) => m['unread'] == true).length}');
      print('================================================\n');
      
      if (userId != null && fullname != null) {
        setState(() {
          _userData = {
            'id': userId,
            'fullname': fullname,
            'email': email ?? '',
            'username': username ?? '',
            'is_verified': isVerified,
          };
        });
      } else {
        print('No user session found in MessagePage');
      }
    } catch (e) {
      print('Error loading user session in MessagePage: $e');
    }
  }

  void _printSessionDebug() async {
    final prefs = await SharedPreferences.getInstance();
    print('\n=== MESSAGE PAGE DEBUG: ALL SESSION DATA ===');
    final keys = prefs.getKeys();
    for (String key in keys) {
      print('$key: ${prefs.get(key)}');
    }
    print('=============================================\n');
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Session Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User: ${_userData?['fullname'] ?? 'Not logged in'}'),
              Text('Email: ${_userData?['email'] ?? 'N/A'}'),
              Text('Username: ${_userData?['username'] ?? 'N/A'}'),
              Text('User ID: ${_userData?['id'] ?? 'N/A'}'),
              Text('Verified: ${_userData?['is_verified'] == true ? 'Yes' : 'No'}'),
              const Divider(),
              Text('Total Conversations: ${_messages.length}'),
              Text('Unread: ${_messages.where((m) => m['unread'] == true).length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _markConversationAsRead(int index) {
    setState(() {
      _messages[index]['unread'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB30000), Color(0xFF8A0000)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData != null 
                        ? 'Welcome ${_userData!['fullname']?.split(' ').first ?? 'User'}! You have ${_messages.where((m) => m['unread'] == true).length} unread'
                        : 'Chat with employers and candidates',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bug_report, color: Colors.white, size: 20),
                      onPressed: _printSessionDebug,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(_messages[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getImagePath(int index) => 'img/$index.jpg';

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            _markConversationAsRead(index);
            _openChat(context, message);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: message['isEmployer']
                                ? const Color(0xFFB30000).withValues(alpha: 0.3)
                                : const Color(0xFF666666).withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            _getImagePath(message['imageIndex']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF5F5F5),
                              child: Icon(
                                message['isEmployer'] ? Icons.business : Icons.person,
                                color: const Color(0xFFB30000),
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (message['unread'])
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB30000),
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2.5),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                message['name'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              message['time'],
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Text(
                          message['jobTitle'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['lastMessage'],
                          style: TextStyle(
                            fontSize: 15,
                            color: message['unread'] ? const Color(0xFF333333) : Colors.grey[600],
                            fontWeight: message['unread'] ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Map<String, dynamic> message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          name: message['name'],
          isEmployer: message['isEmployer'],
          jobTitle: message['jobTitle'],
          imageIndex: message['imageIndex'],
          userData: _userData,
        ),
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final String name;
  final bool isEmployer;
  final String jobTitle;
  final int imageIndex;
  final Map<String, dynamic>? userData;

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.isEmployer,
    required this.jobTitle,
    required this.imageIndex,
    this.userData,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {'text': 'How about Tuesday 2:00 PM?', 'isMe': false, 'time': '10:40 AM'},
    {'text': 'I\'m available then. Does that work for you?', 'isMe': true, 'time': '10:37 AM'},
    {'text': 'Great! We reviewed your profile.', 'isMe': false, 'time': '10:30 AM'},
  ];

  @override
  void initState() {
    super.initState();
    _printChatSession();
  }

  void _printChatSession() {
    print('\n========== CHAT DETAIL PAGE ==========');
    print('Chatting with: ${widget.name}');
    print('Job Title: ${widget.jobTitle}');
    print('User Type: ${widget.isEmployer ? "Employer" : "Candidate"}');
    if (widget.userData != null) {
      print('Logged in as: ${widget.userData!['fullname']}');
      print('User Email: ${widget.userData!['email']}');
    } else {
      print('No user session data available in chat');
    }
    print('=====================================\n');
  }

  String _getImagePath(int index) => 'img/$index.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB30000), Color(0xFF8A0000)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 10,
              right: 20,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _getImagePath(widget.imageIndex),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.isEmployer ? 'Employer' : 'Candidate', 
                        style: const TextStyle(color: Colors.white70, fontSize: 12)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.search, color: Colors.white),
              ],
            ),
          ),
          // Show user info banner if session exists
          if (widget.userData != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF5F5),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Color(0xFFB30000)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chatting as ${widget.userData!['fullname']} (${widget.userData!['email']})',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFB30000)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_chatMessages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  fillColor: const Color(0xFFF5F5F5),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFB30000),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    setState(() {
                      _chatMessages.insert(0, {
                        'text': _messageController.text, 
                        'isMe': true, 
                        'time': 'Now'
                      });
                      _messageController.clear();
                      
                      // Print sent message with user info
                      print('Message sent by ${widget.userData?['fullname'] ?? "User"}: ${_messageController.text}');
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFB30000) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'], 
              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)
            ),
            const SizedBox(height: 4),
            Text(
              message['time'], 
              style: TextStyle(color: isMe ? Colors.white70 : Colors.black45, fontSize: 10)
            ),
          ],
        ),
      ),
    );
  }
}