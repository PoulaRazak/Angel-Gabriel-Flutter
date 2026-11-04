import 'package:flutter/material.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/network/api_client.dart';
import '../../../home-bottombar/view.dart';
import '../login/view.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _collegeController = TextEditingController();
  final _confessorController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedAcademicYear;
  int _selectedGender = 1;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _receiveNotifications = false;
  bool _isLoading = false;

  static const Color _bgColor = Color(0xFFFAF5F0);
  static const Color _cardColor = Colors.white;
  static const Color _primaryMaroon = Color(0xFF7B1E2B);
  static const Color _goldAccent = Color(0xFFD4A843);
  static const Color _textDark = Color(0xFF2C1810);
  static const Color _textSubtle = Color(0xFF8C7B72);
  static const Color _fieldBg = Color(0xFFF3ECE6);
  static const Color _borderColor = Color(0xFFE0D5CC);

  final List<String> _academicYears = [
    'الفرقة الأولى',
    'الفرقة الثانية',
    'الفرقة الثالثة',
    'الفرقة الرابعة',
    'الفرقة الخامسة',
    'الفرقة السادسة',
    'دراسات عليا / خريج',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _collegeController.dispose();
    _confessorController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _normalizeNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cleanPhone = _normalizeNumbers(_phoneController.text);
      final response = await ApiClient.post(
        '/auth/register',
        body: {
          'fullName': _fullNameController.text.trim(),
          'phone': cleanPhone,
          'gender': _selectedGender,
          'university': _collegeController.text.trim(),
          'studyYear': _selectedAcademicYear ?? 'الفرقة الأولى',
          'confessor': _confessorController.text.trim(),
          'password': _passwordController.text.trim(),
          'acceptNotifications': _receiveNotifications,
        },
      );

      if (!mounted) return;
      final String message = (response['message'] ?? 'تم إرسال طلب العضوية بنجاح').toString();
      final bool requiresApproval = response['requiresApproval'] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          backgroundColor: _primaryMaroon,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      if (!requiresApproval && response['token'] != null) {
        final user = response['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
        await CacheHelper.saveSession(
          token: response['token'].toString(),
          userId: (user['id'] ?? '').toString(),
          fullName: (user['fullName'] ?? _fullNameController.text.trim()).toString(),
          phone: (user['phone'] ?? _phoneController.text.trim()).toString(),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Bottombar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), textAlign: TextAlign.right),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFormCard(),
                const SizedBox(height: 24),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryMaroon,
            border: Border.all(color: _goldAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: _primaryMaroon.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.church_rounded, color: _goldAccent, size: 34),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'أُسْرَةُ المَلَاكِ غَبْرِيَالَ',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _primaryMaroon,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'كنيسة السيدة العذراء مريم بالزيتون',
          style: TextStyle(
            fontSize: 13.5,
            color: _textSubtle,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إنشاء حساب جديد',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'انضم إلى عائلتنا الروحية وسجل بياناتك',
              style: TextStyle(fontSize: 13, color: _textSubtle),
            ),
            const SizedBox(height: 24),
            _buildLabel('الاسم الثلاثي'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _fullNameController,
              hint: 'ادخل اسمك بالكامل',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم الثلاثي';
                }
                final parts = v.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
                if (parts.length < 3) {
                  return 'يرجى إدخال الاسم الثلاثي كاملاً';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('النوع'),
            const SizedBox(height: 8),
            _buildGenderSelector(),
            const SizedBox(height: 18),
            _buildLabel('رقم الموبايل'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: '01xxxxxxxxx',
              prefixIcon: Icons.smartphone_rounded,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الموبايل';
                }
                final cleaned = _normalizeNumbers(v);
                if (cleaned.length < 11 || !cleaned.startsWith('01')) {
                  return 'يرجى إدخال رقم موبايل مصري صحيح (11 رقم)';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('الكلية والجامعة'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _collegeController,
              hint: 'مثال: هندسة عين شمس',
              prefixIcon: Icons.school_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'الرجاء إدخال الكلية والجامعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('الفرقة الدراسية'),
            const SizedBox(height: 8),
            _buildDropdownField(),
            const SizedBox(height: 18),
            _buildLabel('أب الاعتراف'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _confessorController,
              hint: 'اسم أب الاعتراف والكنيسة',
              prefixIcon: Icons.person_pin_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'الرجاء إدخال اسم أب الاعتراف';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('كلمة المرور'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textSubtle,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (v.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('تأكيد كلمة المرور'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: '••••••••',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textSubtle,
                  size: 20,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (v != _passwordController.text) {
                  return 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildNotificationRow(),
            const SizedBox(height: 22),
            _buildSubmitButton(),
            const SizedBox(height: 18),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: _textDark,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _selectedGender = 1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _selectedGender == 1 ? _primaryMaroon : _fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == 1 ? _primaryMaroon : _borderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.male_rounded,
                    color: _selectedGender == 1 ? Colors.white : _textSubtle,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ذكر',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _selectedGender == 1 ? Colors.white : _textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _selectedGender = 2),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _selectedGender == 2 ? _primaryMaroon : _fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == 2 ? _primaryMaroon : _borderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.female_rounded,
                    color: _selectedGender == 2 ? Colors.white : _textSubtle,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'أنثى',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _selectedGender == 2 ? Colors.white : _textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextDirection? textDirection,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _textSubtle),
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Icon(prefixIcon, color: _textSubtle, size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryMaroon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedAcademicYear,
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: _textSubtle,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryMaroon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      hint: const Text(
        'اختر الفرقة الدراسية',
        style: TextStyle(fontSize: 13, color: _textSubtle),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textSubtle),
      isExpanded: true,
      dropdownColor: _cardColor,
      borderRadius: BorderRadius.circular(12),
      items: _academicYears.map((year) {
        return DropdownMenuItem<String>(
          value: year,
          child: Text(
            year,
            style: const TextStyle(fontSize: 14, color: _textDark),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedAcademicYear = value);
      },
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'الرجاء اختيار الفرقة الدراسية';
        }
        return null;
      },
    );
  }

  Widget _buildNotificationRow() {
    return GestureDetector(
      onTap: () {
        setState(() => _receiveNotifications = !_receiveNotifications);
      },
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _receiveNotifications ? _primaryMaroon : Colors.transparent,
              border: Border.all(
                color: _receiveNotifications ? _primaryMaroon : _textSubtle,
                width: 1.8,
              ),
            ),
            child: _receiveNotifications
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'أود استلام تنبيهات بمواعيد الاجتماعات والأنشطة الروحية للأسرة',
              style: TextStyle(fontSize: 12.5, color: _textSubtle, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryMaroon,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primaryMaroon.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تسجيل حساب جديد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.person_add_alt_1_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'لديك حساب بالفعل؟ ',
            style: TextStyle(fontSize: 13, color: _textSubtle),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _primaryMaroon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '"هَا أَنَا مُرْسِلٌ مَلاَكِي أَمَامَ وَجْهِكَ"',
          style: TextStyle(
            fontSize: 12.5,
            color: _textSubtle,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == 1 ? 8 : 5,
              height: i == 1 ? 8 : 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == 1 ? _goldAccent : _goldAccent.withOpacity(0.4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
