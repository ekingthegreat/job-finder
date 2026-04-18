import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Ensure this path matches your project structure
import '../../../employer/employer_shell/dashboard.dart';
import '../../../auth/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoggingOut = false;

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
      
      print('\n========== PROFILE PAGE - USER SESSION ==========');
      print('User ID: $userId');
      print('Full Name: $fullname');
      print('Username: $username');
      print('Email: $email');
      print('Is Verified: $isVerified');
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No user session found - using default values');
      }
    } catch (e) {
      print('Error loading user session: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB30000),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear user session data
      await prefs.remove('user_id');
      await prefs.remove('user_fullname');
      await prefs.remove('user_email');
      await prefs.remove('user_username');
      await prefs.remove('is_logged_in');
      await prefs.remove('is_verified');
      
      print('User logged out successfully');
      
      if (mounted) {
        // Use pushReplacementNamed with proper route
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // --- Consistent Typography Scale ---
    final double titleFontSize = (screenWidth * 0.045).clamp(16.0, 20.0); 
    final double bodyFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);  
    final double smallFontSize = (screenWidth * 0.032).clamp(12.0, 14.0); 

    if (_isLoading || _isLoggingOut) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFB30000),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- RED HEADER BANNER (Fixed to prevent overflow) ---
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFB30000), Color(0xFF8A0000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Header row with back button and edit
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Text(
                                    'Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            // Profile image and info
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Container(
                                    width: screenWidth * 0.22,
                                    height: screenWidth * 0.22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'img/3.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.white.withValues(alpha: 0.24),
                                          child: Icon(Icons.person, color: Colors.white, size: screenWidth * 0.1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _userData != null && _userData!['fullname'] != null
                                        ? _userData!['fullname']
                                        : 'John Doe',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleFontSize + 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _userData != null && _userData!['username'] != null
                                        ? '@${_userData!['username']}'
                                        : 'Software Developer',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: smallFontSize,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const EmployerDashboard()),
                                      );
                                    },
                                    icon: const Icon(Icons.business, size: 18),
                                    label: const Text('Switch to Employer'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFFB30000),
                                      elevation: 4,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: smallFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // --- BODY CARDS ---
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          children: [
                            _buildProfileCard(screenWidth, 'Current Role', titleFontSize, [
                              ListTile(
                                leading: const Icon(Icons.person_pin, color: Color(0xFFB30000)),
                                title: Text('Job Seeker', style: TextStyle(fontSize: bodyFontSize)),
                                trailing: _buildBadge('Active', smallFontSize),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  'You are currently viewing as a Job Seeker.',
                                  style: TextStyle(fontSize: smallFontSize, color: Colors.grey[600]),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildProfileCard(screenWidth, 'Personal Information', titleFontSize, [
                              _buildInfoRow(
                                Icons.email, 
                                'Email', 
                                _userData != null && _userData!['email'] != null 
                                    ? _userData!['email'] 
                                    : 'john.doe@gmail.com', 
                                smallFontSize, 
                                bodyFontSize
                              ),
                              _buildInfoRow(Icons.phone, 'Phone', '+1 234 567 8900', smallFontSize, bodyFontSize),
                              _buildInfoRow(Icons.location_on, 'Location', 'Metro Manila, Philippines', smallFontSize, bodyFontSize),
                              _buildInfoRow(Icons.calendar_month, 'Member Since', 'January 2024', smallFontSize, bodyFontSize),
                            ]),
                            const SizedBox(height: 16),
                            _buildProfileCard(screenWidth, 'Professional Information', titleFontSize, [
                              _buildInfoRow(Icons.work, 'Experience', '5+ Years Experience', smallFontSize, bodyFontSize),
                              _buildInfoRow(Icons.school, 'Education', "Bachelor's Degree in Computer Science", smallFontSize, bodyFontSize),
                            ]),
                            const SizedBox(height: 16),
                            _buildProfileCard(screenWidth, 'Resume & Documents', titleFontSize, [
                              _buildActionTile(Icons.description, 'Resume.pdf', 'Last updated 2 days ago', smallFontSize, bodyFontSize),
                              const Divider(height: 1),
                              _buildActionTile(Icons.folder_shared, 'Portfolio.pdf', 'Last updated 1 week ago', smallFontSize, bodyFontSize),
                            ]),
                            const SizedBox(height: 16),
                            _buildProfileCard(screenWidth, 'Account Settings', titleFontSize, [
                              _buildActionTile(Icons.settings, 'Preferences', 'Theme and Notifications', smallFontSize, bodyFontSize),
                              const Divider(height: 1),
                              _buildActionTile(Icons.security, 'Security', 'Password and Privacy', smallFontSize, bodyFontSize),
                            ]),
                            const SizedBox(height: 20),
                            _buildLogoutButton(bodyFontSize, _handleLogout),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- REUSABLE WIDGET HELPERS ---

  Widget _buildProfileCard(double width, String title, double titleSize, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(title, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, double dataSize, double labelSize) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB30000), size: 22),
      title: Text(label, style: TextStyle(fontSize: labelSize, color: Colors.grey[700])),
      trailing: Text(value, style: TextStyle(fontSize: dataSize, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String sub, double subSize, double titleSize) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB30000)),
      title: Text(title, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: TextStyle(fontSize: subSize)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton(double fontSize, VoidCallback onLogout) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFB30000).withValues(alpha: 0.2)
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Color(0xFFB30000)),
        title: Text('Log Out', style: TextStyle(color: const Color(0xFFB30000), fontSize: fontSize, fontWeight: FontWeight.bold)),
        onTap: onLogout,
      ),
    );
  }

  Widget _buildBadge(String text, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFB30000).withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize - 2, color: const Color(0xFFB30000), fontWeight: FontWeight.bold)),
    );
  }
}