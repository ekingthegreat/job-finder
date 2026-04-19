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
  final Map<String, List<Map<String, dynamic>>> _jobApplicants = {};
  bool _isLoading = false;
  bool _isDeleting = false;
  
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
  
  // Date range for contract jobs
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Edit mode
  bool _isEditMode = false;
  int? _editingJobId;
  
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
      
      print('Loading applicants for job $jobId: ${response.body}');
      
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
  
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFB30000)),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
  
  void _editJob(Map<String, dynamic> job) {
    // Populate form with job data
    _titleController.text = job['title'] ?? '';
    _companyController.text = job['company'] ?? '';
    _locationController.text = job['location'] ?? '';
    _salaryController.text = job['salary'] ?? '';
    _vacanciesController.text = (job['vacancies'] ?? 1).toString();
    _descriptionController.text = job['description'] ?? '';
    _requirementsController.text = job['requirements'] ?? '';
    _selectedType = job['job_type'] ?? 'Full-time';
    _uploadedImagePath = job['job_image'];
    
    // Parse dates if they exist
    if (job['start_date'] != null && job['end_date'] != null) {
      _startDate = DateTime.tryParse(job['start_date']);
      _endDate = DateTime.tryParse(job['end_date']);
    } else {
      _startDate = null;
      _endDate = null;
    }
    
    setState(() {
      _isEditMode = true;
      _editingJobId = job['id'];
    });
    
    // Scroll to top to show the edit form
    Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500));
  }
  
  void _cancelEdit() {
    _clearForm();
    setState(() {
      _isEditMode = false;
      _editingJobId = null;
    });
  }
  
  Future<void> _updateJob() async {
    // Validate required fields
    if (_titleController.text.isEmpty) {
      _showError('Please enter job title');
      return;
    }
    
    if (_locationController.text.isEmpty) {
      _showError('Please enter job location');
      return;
    }
    
    // Validate date range for contract jobs
    if (_selectedType == 'Contract' && (_startDate == null || _endDate == null)) {
      _showError('Please select contract date range');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      
      // Prepare job data
      final jobData = {
        'job_id': _editingJobId,
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
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
      };
      
      print('Updating job data: ${json.encode(jobData)}');
      
      final response = await http.put(
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
          _cancelEdit();
          await _loadMyJobs();
          _showSuccess('Job updated successfully!');
        } else {
          _showError(data['message'] ?? 'Failed to update job');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating job: $e');
      _showError('Connection error: $e');
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
    
    // Validate date range for contract jobs
    if (_selectedType == 'Contract' && (_startDate == null || _endDate == null)) {
      _showError('Please select contract date range');
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
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
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
            _startDate = null;
            _endDate = null;
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
  
  Future<void> _toggleJobStatus(int jobId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'closed' : 'active';
    final action = newStatus == 'active' ? 'activate' : 'close';
    
    final shouldToggle = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()} Job'),
        content: Text('Are you sure you want to $action this job posting?'),
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
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );

    if (shouldToggle != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'job_id': jobId,
          'status': newStatus
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _loadMyJobs();
          _showSuccess('Job ${action}ed successfully');
        } else {
          _showError(data['message'] ?? 'Failed to $action job');
        }
      } else {
        _showError('Failed to $action job');
      }
    } catch (e) {
      print('Error toggling job status: $e');
      _showError('Failed to $action job');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deleteJob(int jobId, String jobTitle) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Posting'),
        content: Text('Are you sure you want to delete "$jobTitle"? This action cannot be undone.'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);
    
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
        } else {
          _showError(data['message'] ?? 'Failed to delete job');
        }
      } else {
        _showError('Failed to delete job');
      }
    } catch (e) {
      print('Error deleting job: $e');
      _showError('Failed to delete job');
    } finally {
      setState(() => _isDeleting = false);
    }
  }
  
  Future<void> _updateApplicationStatus(int applicationId, String status) async {
    setState(() => _isLoading = true);
    
    try {
      final apiUrl = await _getApiUrl();
      final response = await http.put(
        Uri.parse('$apiUrl?action=update_application_status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'application_id': applicationId,
          'status': status  // This will be 'accepted' or 'declined'
        }),
      );
      
      print('Update status response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          String displayStatus = status == 'accepted' ? 'shortlisted' : 'rejected';
          _showSuccess('Application $displayStatus');
          // Reload applicants to reflect status change
          for (var job in _myPostedJobs) {
            await _loadApplicants(job['id']);
          }
        } else {
          _showError(data['message'] ?? 'Failed to update status');
        }
      } else {
        _showError('Failed to update status');
      }
    } catch (e) {
      print('Error updating application status: $e');
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
      _startDate = null;
      _endDate = null;
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
      body: _isLoading || _isDeleting
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditMode ? "Edit Job Listing" : "Post New Vacancy",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB30000)),
              ),
              if (_isEditMode)
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text('Cancel Edit', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
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
                  : _uploadedImagePath != null && _uploadedImagePath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost/$_uploadedImagePath',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Failed to load image', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
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
                  initialValue: _selectedType,
                  items: ['Full-time', 'Part-time', 'Remote', 'Contract'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val!;
                      if (_selectedType != 'Contract') {
                        _startDate = null;
                        _endDate = null;
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: "Job Type"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _salaryController, decoration: const InputDecoration(labelText: "Salary Range (₱)", prefixIcon: Icon(Icons.attach_money)))),
            ],
          ),
          
          // Date range picker for contract jobs
          if (_selectedType == 'Contract') ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFB30000), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contract Period*', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            _startDate != null && _endDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select start and end date',
                            style: TextStyle(
                              color: _startDate != null ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          TextField(controller: _descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: "Job Description", alignLabelWithHint: true)),
          const SizedBox(height: 12),
          TextField(controller: _requirementsController, maxLines: 2, decoration: const InputDecoration(labelText: "Requirements", alignLabelWithHint: true)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_isEditMode ? _updateJob : _publishJob),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB30000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _isEditMode ? "Update Listing" : "Publish Listing",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Job Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // Job Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFB30000).withValues(alpha: 0.1),
                    child: job['job_image'] != null && job['job_image'].toString().isNotEmpty
                        ? Image.network(
                            'http://localhost/${job['job_image']}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.work, color: Color(0xFFB30000), size: 30),
                          )
                        : const Icon(Icons.work, color: Color(0xFFB30000), size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildJobChip(Icons.location_on, job['location']),
                          _buildJobChip(Icons.work_outline, job['job_type']),
                          _buildJobChip(Icons.people, '${job['vacancies']} slots'),
                          if (job['salary'] != null && job['salary'].toString().isNotEmpty)
                            _buildJobChip(Icons.attach_money, '₱${job['salary']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Column(
                  children: [
                    // Status Toggle Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: job['status'] == 'active' ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onTap: () => _toggleJobStatus(job['id'], job['status']),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              job['status'] == 'active' ? Icons.check_circle : Icons.cancel,
                              size: 14,
                              color: job['status'] == 'active' ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job['status'] == 'active' ? 'Active' : 'Closed',
                              style: TextStyle(
                                fontSize: 11,
                                color: job['status'] == 'active' ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFFB30000), size: 22),
                          onPressed: () => _editJob(job),
                          tooltip: 'Edit Job',
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                          onPressed: () => _deleteJob(job['id'], job['title']),
                          tooltip: 'Delete Job',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Expandable Section for Applicants
          ExpansionTile(
            leading: const Icon(Icons.people_outline, color: Color(0xFFB30000)),
            title: Text(
              'Applicants (${applicants.length})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.keyboard_arrow_down),
            children: [
              const Divider(height: 1),
              if (applicants.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text("No applicants yet", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: applicants.length,
                  itemBuilder: (context, index) {
                    final applicant = applicants[index];
                    return _buildApplicantCard(applicant, job['id']);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildJobChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFB30000).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFB30000)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFFB30000)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildApplicantCard(Map<String, dynamic> applicant, int jobId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB30000).withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: Color(0xFFB30000)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              applicant['applicant_name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(applicant['applicant_email'], style: const TextStyle(fontSize: 12)),
          ],
        ),
        subtitle: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: applicant['status'] == 'accepted' ? Colors.green.withValues(alpha: 0.1) :
                   applicant['status'] == 'declined' ? Colors.red.withValues(alpha: 0.1) :
                   Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Status: ${applicant['status']}",
            style: TextStyle(
              fontSize: 11,
              color: applicant['status'] == 'accepted' ? Colors.green : 
                     applicant['status'] == 'declined' ? Colors.red : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (applicant['status'] != 'declined')
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () => _updateApplicationStatus(applicant['id'], 'declined'),
                tooltip: 'Decline',
              ),
            if (applicant['status'] != 'accepted')
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green, size: 20),
                onPressed: () => _updateApplicationStatus(applicant['id'], 'accepted'),
                tooltip: 'Accept',
              ),
          ],
        ),
        children: [
          if (applicant['cover_letter'] != null && applicant['cover_letter'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cover Letter:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(applicant['cover_letter']),
                  const SizedBox(height: 8),
                  Text(
                    'Applied on: ${applicant['applied_date']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}