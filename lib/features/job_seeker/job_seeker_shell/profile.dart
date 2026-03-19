import 'package:flutter/material.dart';
// Ensure this path matches your project structure
import '../../../employer/employer_shell/dashboard.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  // --- RED HEADER BANNER ---
                  Container(
                    height: screenHeight * 0.45, 
                    padding: const EdgeInsets.only(bottom: 20),
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
                    child: Stack(
                      children: [
                        Positioned(
                          top: statusBarHeight + 10,
                          left: 10,
                          right: 10,
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
                        
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: statusBarHeight + 20),
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
                                      // FIXED: withOpacity -> withValues
                                      color: Colors.white.withValues(alpha: 0.24),
                                      child: Icon(Icons.person, color: Colors.white, size: screenWidth * 0.1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'John Doe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize + 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Software Developer',
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
                      ],
                    ),
                  ),

                  // --- BODY CARDS ---
                  Padding(
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
                          _buildInfoRow(Icons.email, 'Email', 'john.doe@gmail.com', smallFontSize, bodyFontSize),
                          _buildInfoRow(Icons.phone, 'Phone', '09898878', smallFontSize, bodyFontSize),
                          _buildInfoRow(Icons.location_on, 'Location', 'New York, USA', smallFontSize, bodyFontSize),
                          _buildInfoRow(Icons.calendar_month, 'Date', 'January', smallFontSize, bodyFontSize),
                        ]),
                        const SizedBox(height: 16),

                        _buildProfileCard(screenWidth, 'Professional Information', titleFontSize, [
                          _buildInfoRow(Icons.work, 'Experience', '5 Yrs Experience', smallFontSize, bodyFontSize),
                          _buildInfoRow(Icons.school, 'Education', "Master's in CS", smallFontSize, bodyFontSize),
                        ]),
                        const SizedBox(height: 16),

                        _buildProfileCard(screenWidth, 'Resume & Documents', titleFontSize, [
                          _buildActionTile(Icons.description, 'Resume.pdf', 'Updated 2 days ago', smallFontSize, bodyFontSize),
                          const Divider(height: 1),
                          _buildActionTile(Icons.folder_shared, 'Portfolio.pdf', 'Updated 1 week ago', smallFontSize, bodyFontSize),
                        ]),
                        const SizedBox(height: 16),

                        _buildProfileCard(screenWidth, 'Account Settings', titleFontSize, [
                          _buildActionTile(Icons.settings, 'Preferences', 'Theme and Notifications', smallFontSize, bodyFontSize),
                          const Divider(height: 1),
                          _buildActionTile(Icons.security, 'Security', 'Password and Privacy', smallFontSize, bodyFontSize),
                        ]),
                        const SizedBox(height: 20),

                        _buildLogoutButton(bodyFontSize),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
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
            // FIXED: withOpacity -> withValues
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

  Widget _buildLogoutButton(double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // FIXED: withOpacity -> withValues
          color: const Color(0xFFB30000).withValues(alpha: 0.2)
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Color(0xFFB30000)),
        title: Text('Log Out', style: TextStyle(color: const Color(0xFFB30000), fontSize: fontSize, fontWeight: FontWeight.bold)),
        onTap: () {},
      ),
    );
  }

  Widget _buildBadge(String text, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // FIXED: withOpacity -> withValues
        color: const Color(0xFFB30000).withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize - 2, color: const Color(0xFFB30000), fontWeight: FontWeight.bold)),
    );
  }
}