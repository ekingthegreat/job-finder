import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'applications.dart';
import 'message.dart';
import 'notification.dart';
import 'profile.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JobListingPage(),
  ));
}

class JobListingPage extends StatefulWidget {
  const JobListingPage({super.key});

  @override
  State<JobListingPage> createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobListingPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;

  final List<Widget> _pages = [
    const _JobListContent(),
    const ApplicationsPage(),
    const MessagePage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  static final List<Map<String, dynamic>> _bottomNavItems = [
    {'label': 'Jobs', 'icon': Icons.work_outline, 'activeIcon': Icons.work, 'badge': 0},
    {'label': 'Apps', 'icon': Icons.description_outlined, 'activeIcon': Icons.description, 'badge': 3},
    {'label': 'Chat', 'icon': Icons.chat_bubble_outline, 'activeIcon': Icons.chat_bubble, 'badge': 5},
    {'label': 'Notification', 'icon': Icons.notifications_outlined, 'activeIcon': Icons.notifications, 'badge': 2},
    {'label': 'Profile', 'icon': Icons.person_outline, 'activeIcon': Icons.person, 'badge': 0},
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
      
      // Debug print session information
      print('\n========== JOB LISTING PAGE - USER SESSION ==========');
      print('Is Logged In: $isLoggedIn');
      print('User ID: $userId');
      print('Full Name: $fullname');
      print('Username: $username');
      print('Email: $email');
      print('Is Verified: $isVerified');
      print('=====================================================\n');
      
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
        print('No user session found in JobListingPage');
      }
    } catch (e) {
      print('Error loading user session in JobListingPage: $e');
    }
  }

  void _printSessionDebug() async {
    final prefs = await SharedPreferences.getInstance();
    print('\n=== JOB LISTING PAGE DEBUG: ALL SESSION DATA ===');
    final keys = prefs.getKeys();
    for (String key in keys) {
      print('$key: ${prefs.get(key)}');
    }
    print('================================================\n');
    
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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _bottomNavItems.length,
              (index) => _buildBottomNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index) {
    final bool isSelected = _selectedIndex == index;
    final item = _bottomNavItems[index];
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 360;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container with fixed width ensures the background highlight and badge stay near the icon
            Container(
              width: isSmall ? 50 : 60,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF5F5) : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? item['activeIcon'] : item['icon'],
                    color: isSelected ? const Color(0xFFB30000) : const Color(0xFF666666),
                    size: isSmall ? 20 : 24,
                  ),
                  if (item['badge'] > 0)
                    Positioned(
                      top: -2,
                      right: isSmall ? 8 : 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB30000),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          item['badge'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['label'],
              style: TextStyle(
                fontSize: isSmall ? 10 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFB30000) : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobListContent extends StatelessWidget {
  const _JobListContent();

  final List<Map<String, dynamic>> _jobs = const [
    {
      'title': 'Senior Flutter Developer',
      'company': 'Tech Innovators Inc.',
      'location': 'Remote',
      'salary': '\$120k-\$150k',
      'type': 'Full-time',
      'posted': '2 days ago',
      'description': 'Experienced Flutter developer for mobile applications.',
      'requirements': '5+ years mobile, 3+ years Flutter, Firebase, REST APIs'
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Creative Solutions',
      'location': 'San Francisco, CA',
      'salary': '\$90k-\$120k',
      'type': 'Full-time',
      'posted': '1 week ago',
      'description': 'Create amazing user experiences for web/mobile apps.',
      'requirements': 'Portfolio required, 3+ years design, Figma/Adobe XD'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Debug session from JobListContent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSession(context);
    });
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFB30000), Color(0xFF8A0000)]),
          ),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Your Dream Job', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Browse latest opportunities', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white24, 
                child: IconButton(
                  icon: const Icon(Icons.bug_report, color: Colors.white, size: 20),
                  onPressed: () => _showSessionDebugDialog(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _jobs.length,
            itemBuilder: (context, index) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _buildJobCard(context, _jobs[index], index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _checkUserSession(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    final userId = prefs.getInt('user_id');
    final fullname = prefs.getString('user_fullname');
    final email = prefs.getString('user_email');
    final username = prefs.getString('user_username');
    final isLoggedIn = prefs.getBool('is_logged_in');
    final isVerified = prefs.getBool('is_verified');
    
    print('\n========== JOB LIST CONTENT - USER SESSION ==========');
    print('Is Logged In: $isLoggedIn');
    print('User ID: $userId');
    print('Full Name: $fullname');
    print('Username: $username');
    print('Email: $email');
    print('Is Verified: $isVerified');
    print('=====================================================\n');
  }

  void _showSessionDebugDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    final userId = prefs.getInt('user_id');
    final fullname = prefs.getString('user_fullname');
    final email = prefs.getString('user_email');
    final username = prefs.getString('user_username');
    final isLoggedIn = prefs.getBool('is_logged_in');
    final isVerified = prefs.getBool('is_verified');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged In: ${isLoggedIn == true ? "Yes" : "No"}'),
            const Divider(),
            Text('User ID: ${userId ?? "N/A"}'),
            Text('Full Name: ${fullname ?? "N/A"}'),
            Text('Username: ${username ?? "N/A"}'),
            Text('Email: ${email ?? "N/A"}'),
            Text('Verified: ${isVerified == true ? "Yes" : "No"}'),
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

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyModal(BuildContext context, String jobTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 25),
                Text('Apply for $jobTitle', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('Complete the details below to apply.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 20),
                const Text('Resume / CV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFB30000).withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_rounded, color: Color(0xFFB30000), size: 32),
                      const SizedBox(height: 10),
                      const Text("Upload your file", style: TextStyle(fontWeight: FontWeight.w600)),
                      const Text("PDF or DOCX up to 5MB", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Cover Letter (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Briefly explain why you're a good fit...",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Application Sent!'), backgroundColor: Color(0xFFB30000)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB30000),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Submit Application', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, int index) {
    final String imagePath = 'img/${(index % 7) + 1}.jpg';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(job['company'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(Icons.location_on, job['location']),
                        _chip(Icons.attach_money, job['salary']),
                        _chip(Icons.schedule, job['type']),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(job['description'], style: const TextStyle(color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(10)),
                      child: Text("Requirements: ${job['requirements']}", style: const TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, imagePath),
                      child: Hero(
                        tag: 'jobImage$index',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showApplyModal(context, job['title']),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB30000),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}