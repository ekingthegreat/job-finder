import 'package:enricoso/auth/login.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _scrollController.addListener(() {
      // Adjusted threshold to match the curved header height
      if (_scrollController.offset > 200 && !_isAppBarVisible) {
        setState(() => _isAppBarVisible = true);
      } else if (_scrollController.offset <= 200 && _isAppBarVisible) {
        setState(() => _isAppBarVisible = false);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Find Your Future",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "The most reliable platform for career growth and professional opportunities.",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      
                      _buildFeatureTile(
                        Icons.bolt_rounded,
                        "Instant Applications",
                        "Apply to top-tier companies with a single click.",
                      ),
                      _buildFeatureTile(
                        Icons.verified_user_rounded,
                        "Verified Listings",
                        "Every job post is vetted for security and authenticity.",
                      ),
                      _buildFeatureTile(
                        Icons.auto_graph_rounded,
                        "Career Tracking",
                        "Monitor your application status in real-time.",
                      ),
                      
                      const SizedBox(height: 60),
                      
                      _buildMainButton(
                        "Get Started Now",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  color: Colors.grey[50],
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "© 2026 JOB FINDER SYSTEM",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildAnimatedAppBar(),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      height: 420,
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
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_rounded, size: 85, color: Colors.white),
            ),
            const SizedBox(height: 25),
            const Text(
              "JOB FINDER",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: This now only shows the white background bar without the text/button
  Widget _buildAnimatedAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isAppBarVisible ? MediaQuery.of(context).padding.top + 20 : 0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (_isAppBarVisible)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: const SizedBox.shrink(), // Content removed as requested
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFB30000).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFB30000), size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB30000).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB30000),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}