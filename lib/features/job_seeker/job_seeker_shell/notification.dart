import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Map<String, dynamic>? _userData;
  
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Application Viewed',
      'description': 'Tech Innovators Inc. viewed your application for Senior Flutter Developer',
      'time': 'Just now',
      'type': 'application',
      'read': false,
      'icon': Icons.visibility,
      'color': const Color(0xFF2196F3),
    },
    {
      'id': '2',
      'title': 'Interview Scheduled',
      'description': 'Your interview with Creative Solutions is scheduled for Friday, 2:00 PM',
      'time': '30m ago',
      'type': 'interview',
      'read': false,
      'icon': Icons.calendar_today,
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': '3',
      'title': 'New Job Match',
      'description': 'A new "Mobile Lead" position matches your profile at Global Tech.',
      'time': '2h ago',
      'type': 'job_match',
      'read': true,
      'icon': Icons.work,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': '4',
      'title': 'Offer Received!',
      'description': 'Congratulations! You have received a formal offer from Zenith Systems.',
      'time': '5h ago',
      'type': 'offer',
      'read': false,
      'icon': Icons.card_giftcard,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': '5',
      'title': 'Message Received',
      'description': 'John from Cloud Systems: "Are you available for a quick call tomorrow?"',
      'time': 'Yesterday',
      'type': 'message',
      'read': true,
      'icon': Icons.chat,
      'color': const Color(0xFF00BCD4),
    },
    {
      'id': '6',
      'title': 'Profile Viewed',
      'description': '3 different recruiters viewed your profile in the last 24 hours.',
      'time': '1d ago',
      'type': 'profile',
      'read': true,
      'icon': Icons.person_search,
      'color': const Color(0xFF607D8B),
    },
    {
      'id': '7',
      'title': 'Assessment Required',
      'description': 'Please complete the Dart Logic test for the Junior Dev position.',
      'time': '2d ago',
      'type': 'reminder',
      'read': true,
      'icon': Icons.assignment,
      'color': const Color(0xFF795548),
    },
    {
      'id': '8',
      'title': 'Saved Job Expiring',
      'description': 'The "UI Designer" role at Pixel Perfect closes in 12 hours.',
      'time': '3d ago',
      'type': 'reminder',
      'read': true,
      'icon': Icons.timer,
      'color': const Color(0xFFF44336),
    },
    {
      'id': '9',
      'title': 'Referral Success',
      'description': 'Your friend Sarah just applied using your link. Bonus pending!',
      'time': '1w ago',
      'type': 'referral',
      'read': true,
      'icon': Icons.group_add,
      'color': const Color(0xFF673AB7),
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
      
      // Print session information for debugging
      print('\n========== NOTIFICATION PAGE - USER SESSION ==========');
      print('Is Logged In: $isLoggedIn');
      print('User ID: $userId');
      print('Full Name: $fullname');
      print('Username: $username');
      print('Email: $email');
      print('Is Verified: $isVerified');
      print('Unread Notifications: ${_notifications.where((n) => !n['read']).length}');
      print('======================================================\n');
      
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
        print('No user session found in NotificationPage');
      }
    } catch (e) {
      print('Error loading user session in NotificationPage: $e');
    }
  }

  void _printSessionDebug() async {
    final prefs = await SharedPreferences.getInstance();
    print('\n=== NOTIFICATION PAGE DEBUG: ALL SESSION DATA ===');
    final keys = prefs.getKeys();
    for (String key in keys) {
      print('$key: ${prefs.get(key)}');
    }
    print('=================================================\n');
    
    // Show dialog with session info
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
              Text('Total Notifications: ${_notifications.length}'),
              Text('Unread: ${_notifications.where((n) => !n['read']).length}'),
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

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read'), backgroundColor: Colors.green),
    );
  }

  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cleared'), backgroundColor: Colors.orange),
    );
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB30000), Color(0xFF8A0000)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData != null 
                          ? 'Welcome ${_userData!['fullname']?.split(' ').first ?? 'User'}! You have ${_notifications.where((n) => !n['read']).length} updates'
                          : 'Stay updated on opportunities',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildHeaderActions(),
              ],
            ),
          ),

          _buildBulkActions(),

          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re all caught up!',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildNotificationItem(_notifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_notifications.where((n) => !n['read']).length} unread notifications',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Read all', style: TextStyle(fontSize: 12, color: Color(0xFFB30000))),
          ),
          TextButton(
            onPressed: _clearAllNotifications,
            child: const Text('Clear', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final bool read = notification['read'] as bool? ?? false;
    final Color color = notification['color'] as Color? ?? Colors.grey;
    final String type = notification['type'] as String? ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: () {
          if (!read) {
            _markAsRead(notification['id']);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(notification['icon'], color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: read ? Colors.grey : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: read ? Colors.grey : const Color(0xFFB30000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: read ? Colors.grey : Colors.black54,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!read) {
                              _markAsRead(notification['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${notification['title']}" marked as read'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: read ? Colors.transparent : const Color(0xFFB30000).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: read ? Colors.grey[300]! : const Color(0xFFB30000).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              read ? 'Read' : 'Mark as read',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: read ? Colors.grey : const Color(0xFFB30000),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Debug button added
        IconButton(
          icon: const Icon(Icons.bug_report, color: Colors.white), 
          onPressed: _printSessionDebug,
        ),
        IconButton(
          icon: const Icon(Icons.done_all, color: Colors.white), 
          onPressed: _markAllAsRead,
        ),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2), 
        shape: BoxShape.circle
      ),
      child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
    );
  }
}