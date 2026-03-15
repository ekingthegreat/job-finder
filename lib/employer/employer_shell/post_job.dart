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
      'vacancies': '3',
      'description': 'Leading the development of high-performance mobile apps.',
      'requirements': '5+ years experience, expert in Dart/Flutter.',
      'posted': '2 days ago',
    },
  ];

  // APPLICANTS: Mock data linked by job ID
  final Map<String, List<Map<String, String>>> _jobApplicants = {
    '1': [
      {'name': 'Michael B. Martinez', 'email': 'michael.m@dev.com', 'status': 'Under Review', 'phone': '+63 912 345 6789'},
      {'name': 'Sarah Jenkins', 'email': 's.jenkins@flutter.io', 'status': 'Interviewing', 'phone': '+1 555 010 9988'},
    ],
  };

  // Text Controllers
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _vacanciesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  String _selectedType = 'Full-time';

  // CREATE logic
  void _publishJob() {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Job Title and Location')),
      );
      return;
    }

    setState(() {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _myPostedJobs.insert(0, {
        'id': newId,
        'title': _titleController.text,
        'company': _companyController.text.isEmpty ? 'Confidential' : _companyController.text,
        'type': _selectedType,
        'location': _locationController.text,
        'salary': _salaryController.text,
        'vacancies': _vacanciesController.text.isEmpty ? '1' : _vacanciesController.text,
        'description': _descriptionController.text,
        'requirements': _requirementsController.text,
        'posted': 'Just now',
      });
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job Listing Published!'), backgroundColor: Colors.green),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _companyController.clear();
    _locationController.clear();
    _salaryController.clear();
    _vacanciesController.clear();
    _descriptionController.clear();
    _requirementsController.clear();
  }

  void _deleteJob(String id) {
    setState(() => _myPostedJobs.removeWhere((job) => job['id'] == id));
  }

  // APPLICANT ACTIONS
  void _updateStatus(String jobId, int index, String newStatus) {
    setState(() {
      _jobApplicants[jobId]![index]['status'] = newStatus;
    });
  }

  void _viewUserProfile(Map<String, String> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Applicant Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Email: ${user['email']}"),
            Text("Phone: ${user['phone']}"),
            const SizedBox(height: 8),
            const Text("Resume: resume_v2.pdf", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      Text('Employer Dashboard', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Manage vacancies and hiring', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),
            _buildPostForm(),
            if (_myPostedJobs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(alignment: Alignment.centerLeft, child: Text("Manage Listings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              ..._myPostedJobs.map((job) => _buildJobManagementCard(job)).toList(),
            ],
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Post New Vacancy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB30000))),
          const SizedBox(height: 15),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Job Title*", prefixIcon: Icon(Icons.work_outline))),
          const SizedBox(height: 12),
          TextField(controller: _companyController, decoration: const InputDecoration(labelText: "Company (Optional)", prefixIcon: Icon(Icons.business))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location*", prefixIcon: Icon(Icons.location_on_outlined)))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _vacanciesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Vacancies", prefixIcon: Icon(Icons.group_add_outlined)))),
            ],
          ),
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
              Expanded(child: TextField(controller: _salaryController, decoration: const InputDecoration(labelText: "Salary Range", prefixIcon: Icon(Icons.attach_money)))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: "Job Description", alignLabelWithHint: true)),
          const SizedBox(height: 12),
          TextField(controller: _requirementsController, maxLines: 2, decoration: const InputDecoration(labelText: "Requirements", alignLabelWithHint: true)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _publishJob,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB30000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Publish Listing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const CircleAvatar(backgroundColor: Color(0xFFFFF5F5), child: Icon(Icons.list_alt, color: Color(0xFFB30000))),
        title: Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${job['company']} • ${job['vacancies']} Vacant Slots"),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteJob(job['id'])),
        children: [
          const Divider(height: 1),
          if (applicants.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text("No applicants yet."))
          else
            ...applicants.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, String> user = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Status: ${user['status']}", style: TextStyle(color: user['status'] == 'Accepted' ? Colors.green : user['status'] == 'Declined' ? Colors.red : Colors.blue)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0),
                        onPressed: () => _viewUserProfile(user),
                        child: const Text("View Profile", style: TextStyle(color: Colors.black, fontSize: 11)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _updateStatus(job['id'], idx, 'Declined'),
                          icon: const Icon(Icons.close, color: Colors.red, size: 16),
                          label: const Text("Decline", style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(job['id'], idx, 'Accepted'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0),
                          icon: const Icon(Icons.check, color: Colors.white, size: 16),
                          label: const Text("Accept", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}