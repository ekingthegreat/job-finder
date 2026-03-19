import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:enricoso/auth/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  int _currentStep = 0;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _currentJobController = TextEditingController();
  final _streetAddressController = TextEditingController();
  
  // Form Keys for validation
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Dropdown States for PSGC API
  List<dynamic> _regions = [];
  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];
  List<dynamic> _barangays = [];
  
  String? _selectedRegionCode;
  String? _selectedProvinceCode;
  String? _selectedCityCode;
  String? _selectedBarangayCode;
  
  String? _selectedRegionName;
  String? _selectedProvinceName;
  String? _selectedCityName;
  String? _selectedBarangayName;

  // File pickers for verification
  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieImage;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _currentJobController.dispose();
    _streetAddressController.dispose();
    super.dispose();
  }

  // PSGC API Methods
 Future<void> _fetchRegions() async {
  try {
    final response = await http.get(Uri.parse('https://psgc.cloud/api/regions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _regions = data;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      _showErrorSnackBar('Error fetching regions: $e');
    }
  }
}

Future<void> _fetchProvinces(String regionCode) async {
  try {
    final response = await http.get(Uri.parse('https://psgc.cloud/api/regions/$regionCode/provinces'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _provinces = data;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      _showErrorSnackBar('Error fetching provinces: $e');
    }
  }
}

Future<void> _fetchCities(String provinceCode) async {
  try {
    final response = await http.get(Uri.parse('https://psgc.cloud/api/provinces/$provinceCode/cities-municipalities'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _cities = data;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      _showErrorSnackBar('Error fetching cities: $e');
    }
  }
}

Future<void> _fetchBarangays(String cityCode) async {
  try {
    final response = await http.get(Uri.parse('https://psgc.cloud/api/cities-municipalities/$cityCode/barangays'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _barangays = data;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      _showErrorSnackBar('Error fetching barangays: $e');
    }
  }
}
  // Image picker methods
  Future<void> _pickImage(ImageSource source, String type) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (type == 'front') {
          _frontIdImage = File(image.path);
        } else if (type == 'back') {
          _backIdImage = File(image.path);
        } else if (type == 'selfie') {
          _selfieImage = File(image.path);
        }
      });
    }
  }

 Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime(2005),
    firstDate: DateTime(1950),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFB30000)),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null && mounted) {
    setState(() {
      _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      final age = DateTime.now().year - picked.year;
      _ageController.text = age.toString();
    });
  }
}

 Future<void> _submitRegistration() async {
  if (!_formKey1.currentState!.validate() || 
      !_formKey2.currentState!.validate() || 
      !_formKey3.currentState!.validate()) {
    return;
  }

  if (_passController.text != _confirmPassController.text) {
    _showErrorSnackBar('Passwords do not match');
    return;
  }

  if (_frontIdImage == null || _backIdImage == null || _selfieImage == null) {
    _showErrorSnackBar('Please complete the verification process');
    return;
  }

  setState(() => _isLoading = true);

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8888/enricoso/get.php') // Update with your actual URL
    );

    // Add text fields
    request.fields.addAll({
      'fullname': _nameController.text,
      'username': _usernameController.text,
      'age': _ageController.text,
      'birthday': _birthdayController.text,
      'email': _emailController.text,
      'password': _passController.text,
      'address': _buildFullAddress(),
      'job': _currentJobController.text,
      'street_address': _streetAddressController.text,
      'region': _selectedRegionName ?? '',
      'province': _selectedProvinceName ?? '',
      'city': _selectedCityName ?? '',
      'barangay': _selectedBarangayName ?? '',
    });

    // Add files
    request.files.add(await http.MultipartFile.fromPath('front_id', _frontIdImage!.path));
    request.files.add(await http.MultipartFile.fromPath('back_id', _backIdImage!.path));
    request.files.add(await http.MultipartFile.fromPath('selfie', _selfieImage!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    // Check if widget is still mounted before using context
    if (!mounted) return;

    if (jsonResponse['status'] == 'success') {
      _showSuccessSnackBar('Account created successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      _showErrorSnackBar(jsonResponse['message']);
    }
  } catch (e) {
    // Check if widget is still mounted before using context
    if (!mounted) return;
    _showErrorSnackBar('Error: $e');
  } finally {
    // Check if widget is still mounted before calling setState
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  String _buildFullAddress() {
    List<String> parts = [];
    if (_streetAddressController.text.isNotEmpty) {
      parts.add(_streetAddressController.text);
    }
    if (_selectedBarangayName != null) parts.add(_selectedBarangayName!);
    if (_selectedCityName != null) parts.add(_selectedCityName!);
    if (_selectedProvinceName != null) parts.add(_selectedProvinceName!);
    if (_selectedRegionName != null) parts.add(_selectedRegionName!);
    return parts.join(', ');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB30000),
      ),
    );
  }

  // Dialog methods
  void _showIdCaptureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Upload Government ID",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildIdUploadBox(
                  "Front of ID",
                  _frontIdImage,
                  () => _pickImage(ImageSource.camera, 'front'),
                  () => _pickImage(ImageSource.gallery, 'front'),
                ),
                const SizedBox(height: 10),
                _buildIdUploadBox(
                  "Back of ID",
                  _backIdImage,
                  () => _pickImage(ImageSource.camera, 'back'),
                  () => _pickImage(ImageSource.gallery, 'back'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSelfieCaptureDialog();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB30000)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Next: Selfie", style: TextStyle(color: Color(0xFFB30000), fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdUploadBox(String title, File? image, VoidCallback onCameraTap, VoidCallback onGalleryTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_outlined, size: 30, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onCameraTap,
                    icon: Icon(Icons.camera_alt, size: 16, color: Colors.grey[600]),
                    label: Text('Camera', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onGalleryTap,
                    icon: Icon(Icons.photo_library, size: 16, color: Colors.grey[600]),
                    label: Text('Gallery', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSelfieCaptureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Take a Selfie",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Take a clear photo of your face",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera, 'selfie'),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      image: _selfieImage != null
                          ? DecorationImage(
                              image: FileImage(_selfieImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selfieImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                "Tap to take a selfie",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Back", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (_selfieImage != null) {
                            _showSuccessSnackBar('Selfie uploaded successfully!');
                          } else {
                            _showErrorSnackBar('Please take a selfie first');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB30000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Save", style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFB30000)))
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFFB30000)),
                        ),
                        child: Stepper(
                          elevation: 0,
                          type: StepperType.horizontal,
                          currentStep: _currentStep,
                          physics: const ClampingScrollPhysics(),
                          controlsBuilder: (context, details) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: _currentStep == 0 
                                    ? MainAxisAlignment.center 
                                    : MainAxisAlignment.end,
                                children: [
                                  if (_currentStep > 0) ...[
                                    _buildActionButton(
                                      "BACK",
                                      details.onStepCancel!,
                                      isPrimary: false,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  _buildActionButton(
                                    _currentStep == 2 ? "CREATE ACCOUNT" : "NEXT STEP",
                                    details.onStepContinue!,
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                            );
                          },
                          onStepContinue: () {
                            bool isValid = true;
                            
                            if (_currentStep == 0) {
                              isValid = _formKey1.currentState!.validate();
                              if (isValid && _selectedBarangayName == null) {
                                _showErrorSnackBar('Please complete your address');
                                isValid = false;
                              }
                            } else if (_currentStep == 1) {
                              isValid = _formKey2.currentState!.validate();
                            } else if (_currentStep == 2) {
                              isValid = _formKey3.currentState!.validate();
                              if (isValid && (_frontIdImage == null || _backIdImage == null || _selfieImage == null)) {
                                _showErrorSnackBar('Please complete the verification process');
                                isValid = false;
                              }
                            }
                            
                            if (isValid) {
                              if (_currentStep < 2) {
                                setState(() => _currentStep += 1);
                              } else {
                                _submitRegistration();
                              }
                            }
                          },
                          onStepCancel: () {
                            if (_currentStep > 0) setState(() => _currentStep -= 1);
                          },
                          steps: [
                            Step(
                              isActive: _currentStep >= 0,
                              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                              title: const Text("Personal", style: TextStyle(fontSize: 11)),
                              content: _buildPersonalStep(),
                            ),
                            Step(
                              isActive: _currentStep >= 1,
                              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                              title: const Text("Career", style: TextStyle(fontSize: 11)),
                              content: _buildCareerStep(),
                            ),
                            Step(
                              isActive: _currentStep >= 2,
                              state: _currentStep == 2 ? StepState.editing : StepState.indexed,
                              title: const Text("Verify", style: TextStyle(fontSize: 11)),
                              content: _buildVerificationStep(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
      ),
    );
  }

  Widget _buildPersonalStep() {
    return Form(
      key: _formKey1,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Full Name", Icons.person_outline, _nameController, "e.g. Michael Martinez", validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your full name';
              return null;
            }),
            const SizedBox(height: 16),
            _buildInputField("Username", Icons.alternate_email_rounded, _usernameController, "e.g. mike_dev", validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a username';
              if (value.length < 3) return 'Username must be at least 3 characters';
              return null;
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField("Age", Icons.cake_outlined, _ageController, "Age", enabled: false)),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildInputField("Birthday", Icons.calendar_month_outlined, _birthdayController, "YYYY-MM-DD", validator: (value) {
                        if (value == null || value.isEmpty) return 'Select birthday';
                        return null;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Address (Philippines)", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            _buildStreetAddressField(),
            const SizedBox(height: 10),
            _buildRegionDropdown(),
            const SizedBox(height: 10),
            if (_provinces.isNotEmpty) _buildProvinceDropdown(),
            if (_provinces.isNotEmpty) const SizedBox(height: 10),
            if (_cities.isNotEmpty) _buildCityDropdown(),
            if (_cities.isNotEmpty) const SizedBox(height: 10),
            if (_barangays.isNotEmpty) _buildBarangayDropdown(),
            if (_barangays.isNotEmpty) const SizedBox(height: 16),
            _buildInputField("Email Address", Icons.email_outlined, _emailController, "e.g. michael@example.com", 
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
                return null;
              }
            ),
            const SizedBox(height: 16),
            _buildInputField("Password", Icons.lock_outline_rounded, _passController, "••••••••", isPassword: true, 
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a password';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              }
            ),
            const SizedBox(height: 10),
            _buildInputField("Confirm Password", Icons.lock_outline_rounded, _confirmPassController, "••••••••", isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please confirm your password';
                return null;
              }
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStreetAddressField() {
    return TextFormField(
      controller: _streetAddressController,
      decoration: _inputDecoration(Icons.home_outlined).copyWith(
        hintText: "House/Street/Building",
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

Widget _buildRegionDropdown() {
  return DropdownButtonFormField<String>(
    initialValue: _selectedRegionCode,
    hint: const Text("Select Region", style: TextStyle(fontSize: 13)),
    decoration: _inputDecoration(Icons.location_on_outlined),
    isExpanded: true,
    items: _regions.map<DropdownMenuItem<String>>((region) {
      return DropdownMenuItem<String>(
        value: region['code'] as String?,
        child: Text(region['name'] ?? '', style: const TextStyle(fontSize: 13)),
      );
    }).toList(),
    onChanged: (value) async {
      setState(() {
        _selectedRegionCode = value;
        if (value != null) {
          final selectedRegion = _regions.firstWhere(
            (r) => r['code'] == value,
            orElse: () => null,
          );
          _selectedRegionName = selectedRegion?['name'];
        }
        _selectedProvinceCode = null;
        _selectedProvinceName = null;
        _selectedCityCode = null;
        _selectedCityName = null;
        _selectedBarangayCode = null;
        _selectedBarangayName = null;
        _provinces = [];
        _cities = [];
        _barangays = [];
      });
      if (value != null) {
        await _fetchProvinces(value);
      }
    },
    validator: (value) => value == null ? 'Select a region' : null,
  );
}

 Widget _buildProvinceDropdown() {
  return DropdownButtonFormField<String>(
    initialValue: _selectedProvinceCode,
    hint: const Text("Select Province", style: TextStyle(fontSize: 13)),
    decoration: _inputDecoration(null),
    isExpanded: true,
    items: _provinces.map<DropdownMenuItem<String>>((province) {
      return DropdownMenuItem<String>(
        value: province['code'] as String?,
        child: Text(province['name'] ?? '', style: const TextStyle(fontSize: 13)),
      );
    }).toList(),
    onChanged: (value) async {
      setState(() {
        _selectedProvinceCode = value;
        if (value != null) {
          final selectedProvince = _provinces.firstWhere(
            (p) => p['code'] == value,
            orElse: () => null,
          );
          _selectedProvinceName = selectedProvince?['name'];
        }
        _selectedCityCode = null;
        _selectedCityName = null;
        _selectedBarangayCode = null;
        _selectedBarangayName = null;
        _cities = [];
        _barangays = [];
      });
      if (value != null) {
        await _fetchCities(value);
      }
    },
    validator: (value) => value == null ? 'Select a province' : null,
  );
}
Widget _buildCityDropdown() {
  return DropdownButtonFormField<String>(
    initialValue: _selectedCityCode,
    hint: const Text("Select City/Municipality", style: TextStyle(fontSize: 13)),
    decoration: _inputDecoration(null),
    isExpanded: true,
    items: _cities.map<DropdownMenuItem<String>>((city) {
      return DropdownMenuItem<String>(
        value: city['code'] as String?,
        child: Text(city['name'] ?? '', style: const TextStyle(fontSize: 13)),
      );
    }).toList(),
    onChanged: (value) async {
      setState(() {
        _selectedCityCode = value;
        if (value != null) {
          final selectedCity = _cities.firstWhere(
            (c) => c['code'] == value,
            orElse: () => null,
          );
          _selectedCityName = selectedCity?['name'];
        }
        _selectedBarangayCode = null;
        _selectedBarangayName = null;
        _barangays = [];
      });
      if (value != null) {
        await _fetchBarangays(value);
      }
    },
    validator: (value) => value == null ? 'Select a city/municipality' : null,
  );
}

 Widget _buildBarangayDropdown() {
  return DropdownButtonFormField<String>(
    initialValue: _selectedBarangayCode,
    hint: const Text("Select Barangay", style: TextStyle(fontSize: 13)),
    decoration: _inputDecoration(null),
    isExpanded: true,
    items: _barangays.map<DropdownMenuItem<String>>((barangay) {
      return DropdownMenuItem<String>(
        value: barangay['code'] as String?,
        child: Text(barangay['name'] ?? '', style: const TextStyle(fontSize: 13)),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        _selectedBarangayCode = value;
        if (value != null) {
          final selectedBarangay = _barangays.firstWhere(
            (b) => b['code'] == value,
            orElse: () => null,
          );
          _selectedBarangayName = selectedBarangay?['name'];
        }
      });
    },
    validator: (value) => value == null ? 'Select a barangay' : null,
  );
}

  Widget _buildCareerStep() {
    return Form(
      key: _formKey2,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildInputField(
              "Current Job Title / Profession", 
              Icons.work_outline, 
              _currentJobController, 
              "e.g. Software Developer, Teacher, Engineer",
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your job title';
                return null;
              }
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.info_outline, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  "You can change it later",
                  style: TextStyle(color: Colors.grey[400], fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  const Icon(Icons.work_history_outlined, size: 36, color: Color(0xFFB30000)),
                  const SizedBox(height: 12),
                  const Text(
                    "Complete Your Profile",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add your work experience, skills, and education to get better job matches.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      _showSuccessSnackBar('Full career profile feature coming soon!');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFB30000)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text("Add More Details", style: TextStyle(color: Color(0xFFB30000), fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Form(
      key: _formKey3,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 40, color: Color(0xFFB30000)),
                  const SizedBox(height: 12),
                  const Text(
                    "Identity Verification",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please verify your identity to ensure the safety of our community",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  _buildVerificationOption(
                    Icons.credit_card_outlined,
                    "Government ID",
                    _frontIdImage != null && _backIdImage != null 
                        ? "ID uploaded ✓" 
                        : "Upload front and back of your ID",
                    isCompleted: _frontIdImage != null && _backIdImage != null,
                    onTap: _showIdCaptureDialog,
                  ),
                  const SizedBox(height: 10),
                  _buildVerificationOption(
                    Icons.camera_alt_outlined,
                    "Selfie Verification",
                    _selfieImage != null 
                        ? "Selfie uploaded ✓" 
                        : "Take a photo of yourself",
                    isCompleted: _selfieImage != null,
                    onTap: _showSelfieCaptureDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationOption(IconData icon, String title, String subtitle, 
      {required VoidCallback onTap, bool isCompleted = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.withValues(alpha: 0.1)
                    : const Color(0xFFB30000).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : icon, 
                color: isCompleted ? Colors.green : const Color(0xFFB30000), 
                size: 20
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 13,
                      color: isCompleted ? Colors.green : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.grey[600], 
                      fontSize: 11
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isCompleted ? Icons.check_circle : Icons.arrow_forward_ios, 
              size: 14, 
              color: isCompleted ? Colors.green : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account? ", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
            child: const Text("Sign In", style: TextStyle(color: Color(0xFFB30000), fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {required bool isPrimary}) {
    return Container(
      height: 48,
      width: 160,
      decoration: isPrimary ? BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: const Color(0xFFB30000).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ) : null,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB30000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFB30000), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: Text(text, style: const TextStyle(color: Color(0xFFB30000), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB30000), Color(0xFF8A0000)], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "JOIN US",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 3,
            ),
          ),
          const Text(
            "Start your journey with Job Finder",
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label, 
    IconData icon, 
    TextEditingController? controller, 
    String hint, {
    bool isPassword = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF444444))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          enabled: enabled,
          validator: validator,
          decoration: _inputDecoration(icon).copyWith(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey[400], size: 18),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(IconData? icon) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFB30000), size: 18) : null,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: const BorderSide(color: Color(0xFFB30000), width: 1.2)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }
}