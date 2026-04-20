import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enricoso/auth/registration.dart';
import 'package:enricoso/features/job_seeker/job_seeker_shell/joblisting.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Use the SAME pattern as registration
  Future<String> _getApiUrl() async {
    // Safe platform detection (same as registration)
    try {
      if (Platform.isAndroid) {
        // For Android emulator
        return 'http://192.168.1.38/enricoso/api/login.php';
      } else if (Platform.isIOS) {
        // For iOS simulator
        return 'http://localhost/enricoso/api/login.php';
      } else {
        // For web or other platforms
        return 'http://localhost/enricoso/api/login.php';
      }
    } catch (e) {
      // Fallback URL if platform detection fails
     // print('Platform detection error: $e');
      return 'http://localhost/enricoso/api/login.php';
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobListingPage()),
      );
    }
  }

    Future<void> _handleSignIn() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields", isError: true);
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
      _showSnackBar("Username must be 3-20 characters (letters, numbers, underscore)", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = await _getApiUrl();
      print('Attempting to connect to: $apiUrl');
      
      // Use form data like registration does
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['username'] = username;
      request.fields['password'] = password;
      
      var streamedResponse = await request.send();
      var responseBody = await streamedResponse.stream.bytesToString();
      
      print('Response status code: ${streamedResponse.statusCode}');
      print('Response body: $responseBody');

      if (!mounted) return;

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(responseBody);
        
        if (responseData['status'] == 'success') {
          final userData = responseData['data']['user'];
          await _saveUserSession(userData);
          
          if (!mounted) return;
          
          _showSnackBar("Welcome back, ${userData['fullname']}!", isError: false);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const JobListingPage()),
          );
        } else {
          _showSnackBar(responseData['message'] ?? 'Invalid username or password', isError: true);
        }
      } else {
        _showSnackBar('Server error: ${streamedResponse.statusCode}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      print('Login error details: $e');
      _showSnackBar('Connection error. Please check your internet connection.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('user_fullname', user['fullname']);
    await prefs.setString('user_email', user['email']);
    await prefs.setString('user_username', user['username']);
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_verified', user['is_verified'] ?? false);
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFB30000) : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sign in to discover your next career opportunity.",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildInputField(
                        label: "Username",
                        icon: Icons.person_outline,
                        controller: _usernameController,
                        hint: "Username",
                      ),
                      const SizedBox(height: 25),

                      _buildInputField(
                        label: "Password",
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        isPassword: true,
                        hint: "••••••••",
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showSnackBar("Forgot password feature coming soon!", isError: false);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFB30000),
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB30000).withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB30000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to Job Finder? ",
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFFB30000),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB30000), Color(0xFF8A0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_rounded, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text(
              "JOB FINDER",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Find Your Dream Job Today",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF444444),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.text,
          textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (value) {
            if (isPassword) {
              _handleSignIn();
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFB30000), size: 22),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w400),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB30000), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}