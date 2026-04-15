import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _myPostedJobs = [];
  Map<String, List<Map<String, dynamic>>> _jobApplicants = {};
  bool _isLoading = false;
  
  // Form Controllers
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _vacanciesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  String _selectedType = 'Full-time';
  File? _jobImage;
  String? _uploadedImagePath;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }
  
  Future<String> _getApiUrl() async {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2/enricoso/api/jobs.php';
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
    return 'http://localhost/enricoso/api/jobs.php';
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final fullname = prefs.getString('user_fullname');
      final email = prefs.getString('user_email');
      final username = prefs.getString('user_username');
      
      print('Loading user session - User ID: $userId');
      
      if (userId != null && fullname != null) {
        setState(() {
          _userData = {
            'id': userId,
            'fullname': fullname,
            'email': email ?? '',
            'username': username ?? '',
          };
        });
        await _loadMyJobs();
      } else {
        print('No user session found');
      }
    } catch (e) {
      print('Error loading user session: $e');
    }
  }
  
  Future<void> _loadMyJobs() async {
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      final url = '$apiUrl?action=my_jobs&employer_id=${_userData!['id']}';
      print('Loading jobs from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _myPostedJobs = List<Map<String, dynamic>>.from(data['data']['jobs']);
          });
          
          // Load applicants for each job
          for (var job in _myPostedJobs) {
            await _loadApplicants(job['id']);
          }
        }
      }
    } catch (e) {
      print('Error loading jobs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadApplicants(int jobId) async {
    try {
      final apiUrl = await _getApiUrl();
      final response = await http.get(
        Uri.parse('$apiUrl?action=applicants&job_id=$jobId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _jobApplicants[jobId.toString()] = 
                List<Map<String, dynamic>>.from(data['data']['applicants']);
          });
        }
      }
    } catch (e) {
      print('Error loading applicants: $e');
    }
  }
  
  Future<void> _pickJobImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _jobImage = File(image.path);
      });
      await _uploadJobImage();
    }
  }
  
  Future<void> _uploadJobImage() async {
    if (_jobImage == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl?action=upload_image'));
      request.files.add(await http.MultipartFile.fromPath('job_image', _jobImage!.path));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      
      print('Upload response: $jsonResponse');
      
      if (jsonResponse['status'] == 'success') {
        setState(() {
          _uploadedImagePath = jsonResponse['data']['image_path'];
        });
        _showSuccess('Image uploaded successfully');
      } else {
        _showError(jsonResponse['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showError('Failed to upload image');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _publishJob() async {
    // Validate required fields
    if (_titleController.text.isEmpty) {
      _showError('Please enter job title');
      return;
    }
    
    if (_locationController.text.isEmpty) {
      _showError('Please enter job location');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      
      // Prepare job data
      final jobData = {
        'employer_id': _userData!['id'],
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim().isEmpty 
            ? _userData!['fullname'] 
            : _companyController.text.trim(),
        'job_type': _selectedType,
        'location': _locationController.text.trim(),
        'salary': _salaryController.text.trim(),
        'vacancies': int.tryParse(_vacanciesController.text.trim()) ?? 1,
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'job_image': _uploadedImagePath,
      };
      
      print('Sending job data: ${json.encode(jobData)}');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jobData),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _clearForm();
          await _loadMyJobs();
          _showSuccess('Job posted successfully!');
          
          // Clear the image path after successful post
          setState(() {
            _uploadedImagePath = null;
            _jobImage = null;
          });
        } else {
          _showError(data['message'] ?? 'Failed to post job');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error publishing job: $e');
      _showError('Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deleteJob(int jobId) async {
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'job_id': jobId}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _loadMyJobs();
          _showSuccess('Job deleted successfully');
        }
      }
    } catch (e) {
      print('Error deleting job: $e');
      _showError('Failed to delete job');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateApplicationStatus(int applicationId, String status) async {
    // Implementation for updating application status
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement API call to update application status
      // final apiUrl = await _getApiUrl();
      // final response = await http.put(
      //   Uri.parse(apiUrl),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'application_id': applicationId,
      //     'status': status
      //   }),
      // );
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _showSuccess('Application ${status}d');
      
      // Reload applicants to reflect status change
      // Find the job_id for this application and reload
      for (var entry in _jobApplicants.entries) {
        final jobId = int.parse(entry.key);
        await _loadApplicants(jobId);
      }
    } catch (e) {
      _showError('Failed to update status');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _clearForm() {
    _titleController.clear();
    _companyController.clear();
    _locationController.clear();
    _salaryController.clear();
    _vacanciesController.clear();
    _descriptionController.clear();
    _requirementsController.clear();
    setState(() {
      _jobImage = null;
      _uploadedImagePath = null;
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB30000)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildPostForm(),
                  if (_myPostedJobs.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Manage Listings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    ..._myPostedJobs.map((job) => _buildJobManagementCard(job)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB30000), Color(0xFF8A0000)]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: 12,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Employer Dashboard', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                _userData != null 
                  ? 'Welcome ${_userData!['fullname']?.split(' ').first ?? 'Employer'}! Manage your jobs'
                  : 'Manage vacancies and hiring',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 28),
        ],
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Post New Vacancy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB30000))),
          const SizedBox(height: 15),
          
          // Job Image Picker
          GestureDetector(
            onTap: _pickJobImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _jobImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_jobImage!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Tap to add job image', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
            ),
          ),
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
              onPressed: _isLoading ? null : _publishJob,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB30000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Publish Listing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildJobManagementCard(Map<String, dynamic> job) {
    final applicants = _jobApplicants[job['id'].toString()] ?? [];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: job['job_image'] != null && job['job_image'].toString().isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network('http://localhost/${job['job_image']}', width: 50, height: 50, fit: BoxFit.cover, 
                  errorBuilder: (_, __, ___) => 
                    CircleAvatar(backgroundColor: const Color(0xFFB30000).withValues(alpha: 0.1), 
                    child: const Icon(Icons.work, color: Color(0xFFB30000)))),
              )
            : CircleAvatar(
                backgroundColor: const Color(0xFFB30000).withValues(alpha: 0.1),
                child: const Icon(Icons.work, color: Color(0xFFB30000)),
              ),
        title: Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${job['company']} • ${job['vacancies']} Vacant Slots • ${job['job_type']}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteJob(job['id']),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 ${job['location']}", style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text("💰 ${job['salary'] ?? 'Negotiable'}", style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(job['description'] ?? '', style: const TextStyle(fontSize: 12)),
                const Divider(height: 20),
                const Text("Applicants", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (applicants.isEmpty)
                  const Text("No applicants yet.", style: TextStyle(color: Colors.grey))
                else
                  ...applicants.map((applicant) => _buildApplicantCard(applicant, job['id'])),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildApplicantCard(Map<String, dynamic> applicant, int jobId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(applicant['applicant_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(applicant['applicant_email']),
            Text("Status: ${applicant['status']}", style: TextStyle(
              color: applicant['status'] == 'accepted' ? Colors.green : 
                     applicant['status'] == 'declined' ? Colors.red : Colors.orange,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (applicant['status'] != 'declined')
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _updateApplicationStatus(applicant['id'], 'declined'),
              ),
            if (applicant['status'] != 'accepted')
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _updateApplicationStatus(applicant['id'], 'accepted'),
              ),
          ],
        ),
      ),
    );
  }
}