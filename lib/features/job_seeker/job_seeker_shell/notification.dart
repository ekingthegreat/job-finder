import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
                    children: const [
                      Text(
                        'Notifications',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Stay updated on opportunities',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
            child: ListView.separated(
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
            onPressed: () {},
            child: const Text('Read all', style: TextStyle(fontSize: 12, color: Color(0xFFB30000))),
          ),
          TextButton(
            onPressed: () {},
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
        onTap: () {},
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
                  // FIXED: withOpacity -> withValues
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
                            // FIXED: withOpacity -> withValues
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
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: read ? Colors.transparent : const Color(0xFFB30000).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                // FIXED: withOpacity -> withValues
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
        IconButton(icon: const Icon(Icons.done_all, color: Colors.white), onPressed: () {}),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // FIXED: withOpacity -> withValues
        color: Colors.white.withValues(alpha: 0.2), 
        shape: BoxShape.circle
      ),
      child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
    );
  }
}