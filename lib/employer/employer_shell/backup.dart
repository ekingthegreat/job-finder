import 'package:flutter/material.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  // CRUD: Local State for Jobs
  final List<Map<String, dynamic>> _myPostedJobs = [
    {
      'id': '1',
      'title': 'Senior Flutter Developer',
      'company': 'Tech Innovators Inc.',
      'type': 'Full-time',
      'location': 'Remote',
      'salary': '\$120k - \$150k',
      'posted': '2 days ago',
    },
    {
      'id': '2',
      'title': 'UI/UX Designer',
      'company': 'Creative Solutions',
      'type': 'Contract',
      'location': 'San Francisco',
      'salary': '\$90k - \$110k',
      'posted': '5 days ago',
    }
  ];

  // APPLICANTS: Mock data linked by job ID
  final Map<String, List<Map<String, String>>> _jobApplicants = {
    '1': [
      {'name': 'Michael B. Martinez', 'email': 'michael.m@dev.com', 'status': 'Under Review'},
      {'name': 'Sarah Jenkins', 'email': 's.jenkins@flutter.io', 'status': 'Interviewing'},
    ],
    '2': [
      {'name': 'David Chen', 'email': 'dchen@design.com', 'status': 'Applied'},
    ],
  };

  // Text Controllers for Creating New Jobs
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  String _selectedType = 'Full-time';

  // CREATE logic
  void _publishJob() {
    if (_titleController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    setState(() {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _myPostedJobs.insert(0, {
        'id': newId,
        'title': _titleController.text,
        'company': _companyController.text,
        'type': _selectedType,
        'location': _locationController.text,
        'salary': _salaryController.text,
        'posted': 'Just now',
      });
      _titleController.clear();
      _companyController.clear();
      _locationController.clear();
      _salaryController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job Listing Published!'), backgroundColor: Colors.green),
    );
  }

  // DELETE logic
  void _deleteJob(String id) {
    setState(() {
      _myPostedJobs.removeWhere((job) => job['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // FIXED: Header with const Column to resolve performance lint
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFB30000), Color(0xFF8A0000)]),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 2))],
              ),
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employer Dashboard',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create listings and manage applicants',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Icon(Icons.add_business_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),

            // FORM SECTION (CREATE)
            _buildPostForm(),

            // LIST SECTION (READ / VIEW APPLICANTS)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Manage Active Listings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            ..._myPostedJobs.map((job) => _buildJobManagementCard(job)).toList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPostForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Post New Vacancy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB30000))),
          const SizedBox(height: 15),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Job Title", prefixIcon: Icon(Icons.work_outline))),
          const SizedBox(height: 12),
          TextField(controller: _companyController, decoration: const InputDecoration(labelText: "Company Name", prefixIcon: Icon(Icons.business))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: ['Full-time', 'Part-time', 'Remote', 'Contract'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                  decoration: const InputDecoration(labelText: "Job Type"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _salaryController, decoration: const InputDecoration(labelText: "Salary Range"))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _publishJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB30000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Publish Job Listing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobManagementCard(Map<String, dynamic> job) {
    final applicants = _jobApplicants[job['id']] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const CircleAvatar(backgroundColor: Color(0xFFFFF5F5), child: Icon(Icons.work, color: Color(0xFFB30000), size: 20)),
        title: Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${job['company']} • ${applicants.length} Applicants"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: () => _deleteJob(job['id']),
        ),
        children: [
          const Divider(height: 1),
          if (applicants.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text("No applicants for this position yet.", style: TextStyle(color: Colors.grey)))
          else
            ...applicants.map((user) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
                  leading: const CircleAvatar(radius: 18, child: Icon(Icons.person_outline, size: 20)),
                  title: Text(user['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email']!, style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(8)),
                    child: Text(user['status']!, style: const TextStyle(color: Color(0xFFB30000), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}