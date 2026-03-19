import 'package:flutter/material.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  // Mock data representing the user's specific submission details
  static const Map<String, dynamic> _mockSubmission = {
    'resumeName': 'John_Doe_CV_2024.pdf',
    'coverLetter': 'I am highly interested in this position because of my 5 years of experience with Flutter and Dart. I have built several high-performance apps and love the tech stack at your company.',
    'submittedDate': 'Dec 10, 2023 at 2:30 PM',
  };

  void _showApplicationDetails(BuildContext context, String jobTitle, String status) {
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
                    child: Text(_mockSubmission['resumeName'], style: const TextStyle(fontWeight: FontWeight.w500)),
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
                _mockSubmission['coverLetter'],
                style: const TextStyle(height: 1.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 25),
            Text('Submitted on ${_mockSubmission['submittedDate']}', 
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Professional Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFB30000), Color(0xFF8A0000)]),
            ),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Applications', 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Real-time updates on your journey', 
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
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
            // FIXED: withOpacity -> withValues
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
                    onPressed: () {},
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
        // FIXED: withOpacity -> withValues
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