import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
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
    {
      'name': 'StartUp Ventures',
      'lastMessage': 'We need some additional documents for your application',
      'time': '1 week ago',
      'unread': false,
      'isEmployer': true,
      'imageIndex': 5,
      'jobTitle': 'Product Manager',
    },
    {
      'name': 'Analytics Corp',
      'lastMessage': 'Congratulations! You passed the first round of interviews',
      'time': '2 weeks ago',
      'unread': false,
      'isEmployer': true,
      'imageIndex': 6,
      'jobTitle': 'Data Scientist',
    },
    {
      'name': 'Global Tech Ltd.',
      'lastMessage': 'We\'d like to discuss the salary package with you',
      'time': '3 weeks ago',
      'unread': false,
      'isEmployer': true,
      'imageIndex': 7,
      'jobTitle': 'Mobile Team Lead',
    },
  ];

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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Chat with employers and candidates',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // FIXED: withOpacity -> withValues
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getImagePath(int index) {
    return 'img/$index.jpg';
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            _openChat(context, message);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                                // FIXED: withOpacity -> withValues
                                ? const Color(0xFFB30000).withValues(alpha: 0.3)
                                : const Color(0xFF666666).withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              // FIXED: withOpacity -> withValues
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            _getImagePath(message['imageIndex']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF5F5F5),
                                child: Icon(
                                  message['isEmployer']
                                      ? Icons.business
                                      : Icons.person,
                                  color: message['isEmployer']
                                      ? const Color(0xFFB30000)
                                      : const Color(0xFF666666),
                                  size: 36,
                                ),
                              );
                            },
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['name'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message['jobTitle'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              message['time'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message['lastMessage'],
                          style: TextStyle(
                            fontSize: 15,
                            color: message['unread']
                                ? const Color(0xFF333333)
                                : Colors.grey[600],
                            fontWeight:
                                message['unread'] ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: message['isEmployer']
                                    ? const Color(0xFFFFF5F5)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: message['isEmployer']
                                      // FIXED: withOpacity -> withValues
                                      ? const Color(0xFFB30000).withValues(alpha: 0.3)
                                      : const Color(0xFF666666).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                message['isEmployer'] ? 'Employer' : 'Candidate',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: message['isEmployer']
                                      ? const Color(0xFFB30000)
                                      : const Color(0xFF666666),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.isEmployer,
    required this.jobTitle,
    required this.imageIndex,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'text': 'Hi! We reviewed your application for the Flutter Developer position.',
      'isMe': false,
      'time': '10:30 AM',
    },
    {
      'text': 'Thank you! I\'m really interested in this opportunity.',
      'isMe': true,
      'time': '10:32 AM',
    },
    {
      'text': 'Great! When would you be available for a technical interview?',
      'isMe': false,
      'time': '10:35 AM',
    },
    {
      'text': 'I\'m available any weekday next week. What works for you?',
      'isMe': true,
      'time': '10:37 AM',
    },
    {
      'text': 'How about Tuesday 2:00 PM? We can do it via Google Meet.',
      'isMe': false,
      'time': '10:40 AM',
    },
  ];

  String _getImagePath(int index) {
    return 'img/$index.jpg';
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
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        // FIXED: withOpacity -> withValues
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              // FIXED: withOpacity -> withValues
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              _getImagePath(widget.imageIndex),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF8A0000),
                                  child: Icon(
                                    widget.isEmployer ? Icons.business : Icons.person,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.isEmployer ? 'Employer' : 'Candidate',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // FIXED: withOpacity -> withValues
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                )
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: Colors.white,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    // FIXED: withOpacity -> withValues
                    color: const Color(0xFFB30000).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.work, size: 16, color: Color(0xFFB30000)),
                    const SizedBox(width: 8),
                    Text(
                      widget.jobTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF666666)),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF999999)),
                      ),
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
                    icon: const Icon(Icons.send, color: Colors.white, size: 24),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        setState(() {
                          _chatMessages.insert(
                            0,
                            {
                              'text': _messageController.text,
                              'isMe': true,
                              'time': 'Now',
                            },
                          );
                          _messageController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            message['isMe'] ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message['isMe'])
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  // FIXED: withOpacity -> withValues
                  color: const Color(0xFFB30000).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  _getImagePath(widget.imageIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF5F5F5),
                      child: Icon(
                        widget.isEmployer ? Icons.business : Icons.person,
                        color: const Color(0xFFB30000),
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message['isMe']
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message['isMe']
                        ? const Color(0xFFB30000)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message['isMe']
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: message['isMe']
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // FIXED: withOpacity -> withValues
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 15,
                      color: message['isMe'] ? Colors.white : const Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (message['isMe']) const SizedBox(width: 8),
        ],
      ),
    );
  }
}