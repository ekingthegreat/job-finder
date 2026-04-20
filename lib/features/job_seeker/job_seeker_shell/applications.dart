import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _applications = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<String> _getApiUrl() async {
    try {
      if (Platform.isAndroid) {
        return 'http://192.168.1.38/enricoso/api/myapplication.php';
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
    return 'http://localhost/enricoso/api/myapplication.php';
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userId = prefs.getInt('user_id');
      final fullname = prefs.getString('user_fullname');
      final email = prefs.getString('user_email');
      final username = prefs.getString('user_username');
      final isLoggedIn = prefs.getBool('is_logged_in');
      final isVerified = prefs.getBool('is_verified');
      
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
        });
        await _fetchMyApplications();
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

  Future<void> _fetchMyApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiUrl = await _getApiUrl();
      final url = '$apiUrl?user_id=${_userData!['id']}';
      print('Fetching applications from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            _applications = List<Map<String, dynamic>>.from(data['data']['applications']);
            _isLoading = false;
          });
          print('Loaded ${_applications.length} applications');
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load applications';
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
      print('Error fetching applications: $e');
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelApplication(int applicationId, String jobTitle) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Application'),
        content: Text('Are you sure you want to cancel your application for "$jobTitle"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB30000),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    setState(() => _isLoading = true);

    try {
      final apiUrl = await _getApiUrl();
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'application_id': applicationId,
          'user_id': _userData!['id']
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSuccess('Application cancelled successfully');
          await _fetchMyApplications(); // Refresh the list
        } else {
          _showError(data['message'] ?? 'Failed to cancel application');
        }
      } else {
        _showError('Failed to cancel application');
      }
    } catch (e) {
      print('Error cancelling application: $e');
      _showError('Failed to cancel application');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
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
        child: SingleChildScrollView(
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
                        Text(application['job_title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(application['company_name'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(int.parse(application['status_color'].substring(1, 7), radix: 16) + 0xFF000000).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            application['status_display'],
                            style: TextStyle(
                              color: Color(int.parse(application['status_color'].substring(1, 7), radix: 16) + 0xFF000000),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (application['job_image'] != null && application['job_image'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'http://localhost/${application['job_image']}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.work, size: 40, color: Color(0xFFB30000)),
                      ),
                    ),
                ],
              ),
              const Divider(height: 40),
              
              const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              _infoRow(Icons.location_on, 'Location', application['location']),
              _infoRow(Icons.work_outline, 'Job Type', application['job_type']),
              _infoRow(Icons.attach_money, 'Salary', '₱${application['salary'] ?? 'Negotiable'}'),
              _infoRow(Icons.business, 'Employer', application['employer_name'] ?? 'N/A'),
              _infoRow(Icons.email, 'Employer Email', application['employer_email'] ?? 'N/A'),
              _infoRow(Icons.access_time, 'Applied Date', application['applied_date']),
              
              const SizedBox(height: 20),
              const Text('Cover Letter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application['cover_letter']?.isNotEmpty == true 
                      ? application['cover_letter'] 
                      : 'No cover letter provided',
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),
              ),
              
              const SizedBox(height: 20),
              const Text('Job Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                application['job_description'] ?? 'No description available',
                style: const TextStyle(height: 1.4, color: Colors.black87),
              ),
              
              const SizedBox(height: 20),
              const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                application['job_requirements'] ?? 'No specific requirements',
                style: const TextStyle(height: 1.4, color: Colors.black87),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
                Text(
                  _applications.isEmpty 
                      ? 'No applications yet' 
                      : '${_applications.length} application${_applications.length > 1 ? 's' : ''} submitted',
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
            child: _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchMyApplications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB30000),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _applications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('No applications found', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text('Apply for jobs to see them here', 
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchMyApplications,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: _applications.length,
                          itemBuilder: (context, index) {
                            final application = _applications[index];
                            return _buildApplicationCard(application);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final statusColor = Color(int.parse(application['status_color'].substring(1, 7), radix: 16) + 0xFF000000);
    
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: application['job_image'] != null && application['job_image'].isNotEmpty
                        ? Image.network(
                            'http://localhost/${application['job_image']}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Color(0xFFB30000)),
                          )
                        : const Icon(Icons.business, color: Color(0xFFB30000)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application['job_title'], 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(application['company_name'], 
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              application['status_display'],
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(application['applied_date'], 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                    onPressed: () => _showApplicationDetails(application),
                    child: const Text('View Details', 
                      style: TextStyle(color: Color(0xFFB30000), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                  child: VerticalDivider(),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: application['status'] == 'pending'
                        ? () => _cancelApplication(application['application_id'], application['job_title'])
                        : null,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: application['status'] == 'pending' ? Colors.grey : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}