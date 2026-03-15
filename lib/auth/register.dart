import 'package:flutter/material.dart';
import 'package:enricoso/auth/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  int _currentStep = 0;
  bool _isPasswordVisible = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _currentJobController = TextEditingController();

  // Dropdown States
  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedMunicipality;
  String? _selectedBarangay;

  // Mock data for Philippine locations
  final Map<String, List<String>> _regions = {
    'Luzon': ['Metro Manila', 'Cordillera Administrative Region', 'Ilocos Region', 'Cagayan Valley', 'Central Luzon', 'CALABARZON', 'MIMAROPA', 'Bicol Region'],
    'Visayas': ['Western Visayas', 'Central Visayas', 'Eastern Visayas'],
    'Mindanao': ['Zamboanga Peninsula', 'Northern Mindanao', 'Davao Region', 'SOCCSKSARGEN', 'Caraga', 'Bangsamoro Autonomous Region'],
  };

  final Map<String, List<String>> _provinces = {
    'Metro Manila': ['Manila', 'Quezon City', 'Caloocan', 'Pasig', 'Makati', 'Taguig', 'Mandaluyong', 'Pasay', 'Marikina', 'Parañaque'],
    'CALABARZON': ['Cavite', 'Laguna', 'Batangas', 'Rizal', 'Quezon'],
    'Central Luzon': ['Bulacan', 'Pampanga', 'Nueva Ecija', 'Tarlac', 'Zambales', 'Bataan', 'Aurora'],
    'Western Visayas': ['Iloilo', 'Negros Occidental', 'Capiz', 'Aklan', 'Antique', 'Guimaras'],
    'Central Visayas': ['Cebu', 'Bohol', 'Negros Oriental', 'Siquijor'],
    'Zamboanga Peninsula': ['Zamboanga del Sur', 'Zamboanga del Norte', 'Zamboanga Sibugay'],
  };

  final Map<String, List<String>> _cities = {
    'Zamboanga Sibugay': ['Ipil', 'Titay', 'Roseller Lim', 'Kabasalan', 'Siay', 'Mabuhay', 'Talusan'],
    'Cebu': ['Cebu City', 'Mandaue', 'Lapu-Lapu', 'Talisay', 'Danao'],
    'Iloilo': ['Iloilo City', 'Passi', 'Oton', 'Pavia'],
    'Manila': ['Manila City'],
    'Quezon City': ['Quezon City'],
    'Cavite': ['Bacoor', 'Imus', 'Dasmariñas', 'General Trias'],
  };

  final Map<String, List<String>> _barangays = {
    'Ipil': ['Bacalan', 'Bangkerohan', 'Buluan', 'Caparan', 'Domanguilas', 'Don Andres', 'Ipil Heights', 'Labi', 'Lower Ipil Heights', 'Lumbia', 'Maasin', 'Makilas', 'Pangi', 'Poblacion', 'Sanito', 'Taway'],
    'Titay': ['Barangay 1', 'Barangay 2', 'Barangay 3'],
    'Cebu City': ['Barangay 1', 'Barangay 2', 'Barangay 3'],
    'Manila City': ['Barangay 1', 'Barangay 2', 'Barangay 3'],
  };

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
    super.dispose();
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
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.month}/${picked.day}/${picked.year}";
        // Auto-calculate age
        final age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

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
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_outlined, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        "Front of ID",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_outlined, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        "Back of ID",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
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
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to take a selfie",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification photos uploaded successfully!'),
                              backgroundColor: Color(0xFFB30000),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB30000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Submit", style: TextStyle(fontSize: 13)),
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
        child: Column(
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
                      if (_currentStep < 2) {
                        setState(() => _currentStep += 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account creation functionality will be implemented here'),
                            backgroundColor: Color(0xFFB30000),
                          ),
                        );
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField("Full Name", Icons.person_outline, _nameController, "e.g. Michael Martinez"),
          const SizedBox(height: 16),
          _buildInputField("Username", Icons.alternate_email_rounded, _usernameController, "e.g. mike_dev"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputField("Age", Icons.cake_outlined, _ageController, "Age")),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildInputField("Birthday", Icons.calendar_month_outlined, _birthdayController, "MM/DD/YYYY"),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Address (Philippines)", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF444444))),
          const SizedBox(height: 8),
          _buildDropdown("Region", _regions.keys.toList(), _selectedRegion, (val) {
            setState(() {
              _selectedRegion = val;
              _selectedProvince = null;
              _selectedCity = null;
              _selectedMunicipality = null;
              _selectedBarangay = null;
            });
          }),
          const SizedBox(height: 10),
          if (_selectedRegion != null)
            _buildDropdown("Province", _regions[_selectedRegion] ?? [], _selectedProvince, (val) {
              setState(() {
                _selectedProvince = val;
                _selectedCity = null;
                _selectedMunicipality = null;
                _selectedBarangay = null;
              });
            }),
          if (_selectedRegion != null) const SizedBox(height: 10),
          if (_selectedProvince != null && _provinces.containsKey(_selectedProvince))
            _buildDropdown("City/Province", _provinces[_selectedProvince] ?? [], _selectedCity, (val) {
              setState(() {
                _selectedCity = val;
                _selectedMunicipality = null;
                _selectedBarangay = null;
              });
            }),
          if (_selectedProvince != null && _provinces.containsKey(_selectedProvince)) const SizedBox(height: 10),
          if (_selectedCity != null && _cities.containsKey(_selectedCity))
            _buildDropdown("Municipality", _cities[_selectedCity] ?? [], _selectedMunicipality, (val) {
              setState(() {
                _selectedMunicipality = val;
                _selectedBarangay = null;
              });
            }),
          if (_selectedCity != null && _cities.containsKey(_selectedCity)) const SizedBox(height: 10),
          if (_selectedMunicipality != null && _barangays.containsKey(_selectedMunicipality))
            _buildDropdown("Barangay", _barangays[_selectedMunicipality] ?? [], _selectedBarangay, (val) {
              setState(() => _selectedBarangay = val);
            }),
          if (_selectedMunicipality != null && _barangays.containsKey(_selectedMunicipality)) const SizedBox(height: 16),
          _buildInputField("Email Address", Icons.email_outlined, _emailController, "e.g. michael@example.com"),
          const SizedBox(height: 16),
          _buildInputField("Password", Icons.lock_outline_rounded, _passController, "••••••••", isPassword: true),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCareerStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInputField(
            "Current Job Title / Profession", 
            Icons.work_outline, 
            _currentJobController, 
            "e.g. Software Developer, Teacher, Engineer"
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Full career profile feature coming soon!'),
                        backgroundColor: Color(0xFFB30000),
                      ),
                    );
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
    );
  }

  Widget _buildVerificationStep() {
    return SingleChildScrollView(
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
                  "Upload front and back of your ID",
                  onTap: _showIdCaptureDialog,
                ),
                const SizedBox(height: 10),
                _buildVerificationOption(
                  Icons.camera_alt_outlined,
                  "Selfie Verification",
                  "Take a photo of yourself",
                  onTap: _showSelfieCaptureDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildVerificationOption(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFB30000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFB30000), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text("Select $label", style: const TextStyle(fontSize: 13, color: Colors.grey)),
      decoration: _inputDecoration(null),
      items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      isExpanded: true,
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
          BoxShadow(color: const Color(0xFFB30000).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
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
              color: Colors.white.withOpacity(0.15),
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

  Widget _buildInputField(String label, IconData icon, TextEditingController? controller, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF444444))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
    );
  }
}