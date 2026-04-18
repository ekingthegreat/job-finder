import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

class _JobListContent extends StatefulWidget {
  const _JobListContent();

  @override
  State<_JobListContent> createState() => _JobListContentState();
}

class _JobListContentState extends State<_JobListContent> {
  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<String> _getApiUrl() async {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2/enricoso/api/get_jobs.php';
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
    return 'http://localhost/enricoso/api/get_jobs.php';
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiUrl = await _getApiUrl();
      print('Fetching jobs from: $apiUrl');
      
      final response = await http.get(Uri.parse(apiUrl));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            _jobs = List<Map<String, dynamic>>.from(data['data']['jobs']);
            _isLoading = false;
          });
          print('Loaded ${_jobs.length} jobs');
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load jobs';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _applyForJob(Map<String, dynamic> job) async {
    print('Apply button clicked for job: ${job['title']}');
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userFullname = prefs.getString('user_fullname');
    final userEmail = prefs.getString('user_email');
    
    print('User ID: $userId');
    print('User Fullname: $userFullname');
    print('User Email: $userEmail');
    
    if (userId == null) {
      _showError('Please login to apply for jobs');
      return;
    }
    
    _showApplyModal(context, job, userId, userFullname, userEmail);
  }

  void _showApplyModal(BuildContext context, Map<String, dynamic> job, int userId, String? userFullname, String? userEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String coverLetter = '';
            bool isSubmitting = false;
            
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
                      decoration: BoxDecoration(
                        color: Colors.grey[300], 
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Apply for ${job['title']}', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${job['company']} • ${job['location']}', 
                    style: const TextStyle(color: Colors.grey, fontSize: 14)
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Resume / CV', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _showError('Resume upload coming soon');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFB30000).withValues(alpha: 0.08)
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.cloud_upload_rounded, color: Color(0xFFB30000), size: 32),
                          SizedBox(height: 10),
                          Text("Upload your file", style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            "PDF or DOCX up to 5MB", 
                            style: TextStyle(color: Colors.grey, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cover Letter (Optional)', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 4,
                    onChanged: (value) {
                      coverLetter = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Briefly explain why you're a good fit...",
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), 
                        borderSide: BorderSide.none
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : () async {
                        print('Submit button pressed');
                        setModalState(() => isSubmitting = true);
                        
                        // TODO: Implement actual application submission to backend
                        // This is where you would send the application to your API
                        await _submitApplication(job, userId, userFullname, userEmail, coverLetter);
                        
                        if (mounted) {
                          Navigator.pop(context);
                          _showSuccess('Application submitted for ${job['title']}!');
                        }
                        
                        setModalState(() => isSubmitting = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB30000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white, 
                                strokeWidth: 2
                              ),
                            )
                          : const Text(
                              'Submit Application', 
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 16
                              )
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitApplication(Map<String, dynamic> job, int userId, String? userFullname, String? userEmail, String coverLetter) async {
    try {
      // Get API URL for submission
      final apiUrl = await _getApiUrlForSubmission();
      print('Submitting application to: $apiUrl');
      
      // Prepare the data
      final applicationData = {
        'job_id': job['id'],
        'user_id': userId,
        'user_fullname': userFullname ?? '',
        'user_email': userEmail ?? '',
        'cover_letter': coverLetter,
        'status': 'pending',
        'applied_date': DateTime.now().toIso8601String(),
      };
      
      print('Application data: $applicationData');
      
      // Send to backend
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(applicationData),
      );
      
      print('Submission response status: ${response.statusCode}');
      print('Submission response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('Application submitted successfully');
        } else {
          print('Application submission failed: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting application: $e');
      // Even if backend fails, we'll still show success for now
      // Remove this once backend is implemented
    }
  }

  Future<String> _getApiUrlForSubmission() async {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2/enricoso/api/submit_application.php';
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
    return 'http://localhost/enricoso/api/submit_application.php';
  }

  void _showFullScreenImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    final fullUrl = imageUrl.startsWith('http') 
        ? imageUrl 
        : 'http://localhost/$imageUrl';
    
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
                child: Image.network(
                  fullUrl,
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFB30000), Color(0xFF8A0000)]),
          ),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Your Dream Job', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Browse latest opportunities', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB30000)),
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchJobs,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB30000),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _jobs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text('No jobs available', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : PageView.builder(
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

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, int index) {
    final String? imageUrl = job['job_image'];
    final String salary = job['salary']?.toString() ?? 'Negotiable';
    final String salaryDisplay = salary.contains('₱') ? salary : '₱$salary';
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    
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
                  if (job['employer_name'] != null)
                    Text(job['employer_name'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                        _chip(Icons.attach_money, salaryDisplay),
                        _chip(Icons.schedule, job['job_type']),
                        if (job['vacancies'] != null)
                          _chip(Icons.people, '${job['vacancies']} slots'),
                        if (job['posted_date'] != null)
                          _chip(Icons.access_time, job['posted_date']),
                      ],
                    ),
                    if (job['contract_period'] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Contract Period: ${job['contract_period']}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(job['description'] ?? 'No description available', style: const TextStyle(color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(10)),
                      child: Text("Requirements: ${job['requirements'] ?? 'No specific requirements'}", style: const TextStyle(fontSize: 13)),
                    ),
                    if (hasImage) ...[
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => _showFullScreenImage(context, imageUrl),
                        child: Hero(
                          tag: 'jobImage$index',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'http://localhost/$imageUrl',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('Image not available', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Color(0xFFB30000)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 15),
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB30000), Color(0xFF8A0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_outline, size: 40, color: Colors.white.withValues(alpha: 0.8)),
                            const SizedBox(height: 8),
                            Text(
                              job['company'] ?? 'Company',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hiring Now!',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  onPressed: () => _applyForJob(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB30000),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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