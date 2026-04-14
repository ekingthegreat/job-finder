import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load user data
      final userId = prefs.getInt('user_id');
      final fullname = prefs.getString('user_fullname');
      final email = prefs.getString('user_email');
      final username = prefs.getString('user_username');
      final isLoggedIn = prefs.getBool('is_logged_in');
      final isVerified = prefs.getBool('is_verified');
      
      // Print session information for debugging
      print('\n========== APPLICATIONS PAGE - USER SESSION ==========');
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('WARNING: No user session found in ApplicationsPage');
      }
    } catch (e) {
      print('Error loading user session in ApplicationsPage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Updated mock data to be dynamic based on user
  Map<String, dynamic> _getMockSubmission() {
    final userName = _userData?['fullname']?.split(' ').first ?? 'User';
    final userEmail = _userData?['email'] ?? 'user@example.com';
    
    return {
      'resumeName': '${userName}_CV_2024.pdf',
      'coverLetter': 'I am highly interested in this position because of my 5 years of experience with Flutter and Dart. I have built several high-performance apps and love the tech stack at your company.\n\nContact: $userEmail',
      'submittedDate': 'Dec 10, 2023 at 2:30 PM',
    };
  }

  void _printSessionDebug() async {
    final prefs = await SharedPreferences.getInstance();
    print('\n=== DEBUG: ALL SESSION KEYS AND VALUES ===');
    final keys = prefs.getKeys();
    for (String key in keys) {
      print('$key: ${prefs.get(key)}');
    }
    print('==========================================\n');
    
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
              const Text('Total applications: 3', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showApplicationDetails(BuildContext context, String jobTitle, String status) {
    final mockSubmission = _getMockSubmission();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 15,
          bottom: MediaQuery.of(context).padding.bottom + 20,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Status: $status', style: const TextStyle(color: Colors.grey)),
                      if (_userData != null) ...[
                        const SizedBox(height: 4),
                        Text('Applicant: ${_userData!['fullname']}', 
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB30000))),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.verified, color: Colors.blue, size: 28),
              ],
            ),
            const Divider(height: 40),
            
            const Text('Your Submitted Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xFFB30000)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(mockSubmission['resumeName'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const Icon(Icons.file_download_outlined, color: Colors.grey),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            const Text('Cover Letter Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mockSubmission['coverLetter'],
                style: const TextStyle(height: 1.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 25),
            Text('Submitted on ${mockSubmission['submittedDate']}', 
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFB30000),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Professional Header with user info
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFB30000), Color(0xFF8A0000)]),
            ),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Applications', 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Real-time updates on your journey', 
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                if (_userData != null) ...[
                  const SizedBox(height: 8),
                  Text('Welcome back, ${_userData!['fullname']}!', 
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Debug button to print session
                _buildDebugButton(),
                const SizedBox(height: 10),
                
                _buildApplicationCard(
                  context,
                  jobTitle: 'Senior Flutter Developer',
                  company: 'Tech Innovators Inc.',
                  status: 'Under Review',
                  statusColor: Colors.orange,
                  date: 'Dec 10, 2023',
                ),
                _buildApplicationCard(
                  context,
                  jobTitle: 'UI/UX Designer',
                  company: 'Creative Solutions',
                  status: 'Interviewing',
                  statusColor: Colors.blue,
                  date: 'Dec 08, 2023',
                ),
                _buildApplicationCard(
                  context,
                  jobTitle: 'Offer Received',
                  company: 'Analytics Corp',
                  status: 'Selected',
                  statusColor: Colors.green,
                  date: 'Nov 28, 2023',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: _printSessionDebug,
        icon: const Icon(Icons.bug_report, size: 18),
        label: const Text('Debug Session Info'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: const Color(0xFFB30000),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context, {
    required String jobTitle,
    required String company,
    required String status,
    required Color statusColor,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: Color(0xFFB30000)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(company, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statusBadge(status, statusColor),
                          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _showApplicationDetails(context, jobTitle, status),
                    child: const Text('View Details', style: TextStyle(color: Color(0xFFB30000), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                  child: VerticalDivider(),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Show cancellation dialog with user info
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cancel Application'),
                          content: Text('Are you sure you want to cancel your application for $jobTitle?\n\n${_userData != null ? 'Applicant: ${_userData!['fullname']}' : ''}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Application cancelled'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}