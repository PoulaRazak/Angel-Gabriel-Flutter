import 'package:flutter/material.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/view/login/view.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String university;
  final String studyYear;
  final String confessor;
  final String membershipTitle;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.university,
    required this.studyYear,
    required this.confessor,
    required this.membershipTitle,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? university,
    String? studyYear,
    String? confessor,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      studyYear: studyYear ?? this.studyYear,
      confessor: confessor ?? this.confessor,
      membershipTitle: membershipTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: (json['id'] ?? '').toString(),
        fullName: (json['fullName'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        university: (json['university'] ?? '').toString(),
        studyYear: (json['studyYear'] ?? 'الفرقة الأولى').toString(),
        confessor: (json['confessor'] ?? '').toString(),
        membershipTitle: (json['membershipTitle'] ?? 'عضو بأسرة الملاك غبريال').toString(),
        avatarUrl: json['avatarUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'university': university,
        'studyYear': studyYear,
        'confessor': confessor,
        'membershipTitle': membershipTitle,
        'avatarUrl': avatarUrl,
      };
}

class ProfileApiService {
  static Future<UserProfile> fetchUserProfile() async {
    final json = await ApiClient.get('/profile');
    return UserProfile.fromJson(json);
  }

  static Future<bool> updateUserProfile(UserProfile profile) async {
    final json = await ApiClient.put('/profile', body: profile.toJson());
    return json['success'] == true;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryCrimson = Color(0xFF7C1D2D);
  static const Color accentGold = Color(0xFFD99B26);
  static const Color scaffoldBg = Color(0xFFFCF8F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color fieldBg = Color(0xFFF3ECE6);
  static const Color textDark = Color(0xFF2B1B1E);
  static const Color textMuted = Color(0xFF7A6A6D);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _universityController;
  late final TextEditingController _confessorController;

  final List<String> _studyYears = const [
    'الفرقة الأولى',
    'الفرقة الثانية',
    'الفرقة الثالثة',
    'الفرقة الرابعة',
    'الفرقة الخامسة',
    'الفرقة السادسة',
    'دراسات عليا / خريج',
  ];

  String? _selectedStudyYear;
  UserProfile? _currentProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _universityController = TextEditingController();
    _confessorController = TextEditingController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _confessorController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ProfileApiService.fetchUserProfile();
      if (!mounted) return;
      setState(() {
        _currentProfile = profile;
        _nameController.text = profile.fullName;
        _phoneController.text = profile.phone;
        _universityController.text = profile.university;
        _confessorController.text = profile.confessor;
        _selectedStudyYear = _studyYears.contains(profile.studyYear)
            ? profile.studyYear
            : _studyYears.first;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('حدث خطأ أثناء تحميل البيانات', isError: true);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate() || _currentProfile == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final updatedProfile = _currentProfile!.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        university: _universityController.text.trim(),
        studyYear: _selectedStudyYear,
        confessor: _confessorController.text.trim(),
      );

      final success = await ProfileApiService.updateUserProfile(updatedProfile);
      if (!mounted) return;

      if (success) {
        setState(() => _currentProfile = updatedProfile);
        _showSnackBar('تم حفظ التغييرات بنجاح');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    await CacheHelper.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : primaryCrimson,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: primaryCrimson,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _logout,
              tooltip: 'تسجيل الخروج',
              icon: const Icon(Icons.logout_rounded, color: primaryCrimson),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryCrimson),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildAvatarHeader(),
                        const SizedBox(height: 28),
                        _buildFormCard(),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentGold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 56,
                backgroundColor: Color(0xFFEBDAD3),
                child: Icon(
                  Icons.person_rounded,
                  size: 64,
                  color: primaryCrimson,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showSnackBar('تم تحديث البيانات الشخصية');
              },
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: primaryCrimson,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _currentProfile?.fullName ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: primaryCrimson,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_rounded, color: accentGold, size: 18),
            const SizedBox(width: 6),
            Text(
              _currentProfile?.membershipTitle ?? '',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('الاسم الثلاثي'),
          _buildTextField(
            controller: _nameController,
            hint: 'أدخل الاسم الثلاثي',
            prefixIcon: Icons.person_outline_rounded,
            validator: (val) => (val == null || val.trim().isEmpty)
                ? 'يرجى إدخال الاسم الثلاثي'
                : null,
          ),
          const SizedBox(height: 18),
          _buildLabel('رقم الموبايل'),
          _buildTextField(
            controller: _phoneController,
            hint: '01xxxxxxxxx',
            prefixIcon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            validator: (val) => (val == null || val.trim().length < 11)
                ? 'يرجى إدخال رقم موبايل صحيح'
                : null,
          ),
          const SizedBox(height: 18),
          _buildLabel('الجامعة والكلية'),
          _buildTextField(
            controller: _universityController,
            hint: 'مثال: جامعة عين شمس - كلية الهندسة',
            prefixIcon: Icons.school_outlined,
          ),
          const SizedBox(height: 18),
          _buildLabel('الفرقة الدراسية'),
          _buildDropdownField(),
          const SizedBox(height: 18),
          _buildLabel('أب الاعتراف'),
          _buildTextField(
            controller: _confessorController,
            hint: 'أدخل اسم أب الاعتراف',
            prefixIcon: Icons.spa_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: textMuted,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 14),
        filled: true,
        fillColor: fieldBg,
        prefixIcon: Icon(prefixIcon, color: primaryCrimson, size: 22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryCrimson, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedStudyYear,
      icon: const Icon(
        Icons.unfold_more_rounded,
        color: textMuted,
        size: 20,
      ),
      dropdownColor: cardBg,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldBg,
        prefixIcon: const Icon(
          Icons.layers_outlined,
          color: primaryCrimson,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryCrimson, width: 1.5),
        ),
      ),
      items: _studyYears
          .map((year) => DropdownMenuItem(value: year, child: Text(year)))
          .toList(),
      onChanged: (value) => setState(() => _selectedStudyYear = value),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfileChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primaryCrimson.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'حفظ التغييرات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
      ),
    );
  }
}
