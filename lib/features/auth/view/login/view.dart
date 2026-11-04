import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/network/api_client.dart';
import '../../../home-bottombar/view.dart';
import '../signup/view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF7A1428);
  static const Color goldColor = Color(0xFFF3B14E);
  static const Color bgColor = Color(0xFFFFF8F5);
  static const Color cardColor = Colors.white;
  static const Color inputFillColor = Color(0xFFF3ECEA);
  static const Color textDarkColor = Color(0xFF2B191B);
  static const Color textMutedColor = Color(0xFF8C7A7B);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cleanPhone = _normalizeNumbers(_phoneController.text);
      final response = await ApiClient.post(
        '/auth/login',
        body: {
          'phone': cleanPhone,
          'password': _passwordController.text.trim(),
        },
      );

      final user = response['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
      await CacheHelper.saveSession(
        token: (response['token'] ?? '').toString(),
        userId: (user['id'] ?? '').toString(),
        fullName: (user['fullName'] ?? '').toString(),
        phone: (user['phone'] ?? cleanPhone).toString(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((response['message'] ?? 'تم تسجيل الدخول بنجاح').toString()),
          backgroundColor: primaryColor,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Bottombar()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
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
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildFormCard(),
                  const SizedBox(height: 28),
                  _buildFooter(),
                ],
              ),
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
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: goldColor.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.church_rounded,
                  color: goldColor,
                  size: 44,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'أُسْرَةُ المَلَاكِ غَبْرِيَالَ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: primaryColor,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'كنيسة السيدة العذراء مريم بالزيتون',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textMutedColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 3.5,
          decoration: BoxDecoration(
            color: goldColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textDarkColor,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            const Text(
              'مرحباً بك مجدداً في رحاب الأسرة',
              style: TextStyle(fontSize: 13, color: textMutedColor),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('رقم الموبايل'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'برجاء إدخال رقم الموبايل';
                }
                final cleaned = _normalizeNumbers(value);
                if (cleaned.length < 11 || !cleaned.startsWith('01')) {
                  return 'برجاء إدخال رقم موبايل مصري صحيح (11 رقم)';
                }
                return null;
              },
              decoration: _inputDecoration(
                hintText: '01xxxxxxxxx',
                prefixIcon: Icons.phone_iphone_rounded,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFieldLabel('كلمة المرور'),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تواصل مع خادم النظام بالاجتماع لإعادة تعيين كلمة المرور'),
                      ),
                    );
                  },
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'برجاء إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
              decoration: _inputDecoration(
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: textMutedColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
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
                            'دخول',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.login_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade200)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'أو',
                    style: TextStyle(fontSize: 12, color: textMutedColor),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade200)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ليس لديك حساب؟ ',
                  style: TextStyle(fontSize: 13, color: textMutedColor),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '"فَرِحْتُ بِالْقَائِلِينَ لِي: إِلَى بَيْتِ الرَّبِّ نَذْهَبُ"',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textMutedColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(),
            const SizedBox(width: 6),
            _buildDot(),
            const SizedBox(width: 6),
            _buildDot(),
          ],
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: goldColor.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textDarkColor,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: textMutedColor.withOpacity(0.6), fontSize: 14),
      filled: true,
      fillColor: inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Icon(prefixIcon, color: textMutedColor, size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
