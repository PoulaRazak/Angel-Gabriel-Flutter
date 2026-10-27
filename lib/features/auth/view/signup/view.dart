import 'package:angel_gabriel/features/auth/view/login/view.dart';
import 'package:angel_gabriel/features/home-bottombar/view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/app-colors.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();
  final _confessorController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _studyYear;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptNotifications = true;

  static const _studyYears = [
    'السنة الأولى',
    'السنة الثانية',
    'السنة الثالثة',
    'السنة الرابعة',
    'السنة الخامسة',
    'السنة السادسة',
    'خريج',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _confessorController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ Logic
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: add your register logic / API call
    }
  }

  /// Returns 0..4
  int _passwordStrength(String p) {
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 6) score++;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(p) && RegExp(r'\d').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p) ||
        (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p))) {
      score++;
    }
    return score.clamp(0, 4);
  }

  String _strengthLabel(int s) {
    switch (s) {
      case 1:
        return 'ضعيفة';
      case 2:
        return 'مقبولة';
      case 3:
        return 'جيدة';
      case 4:
        return 'قوية';
      default:
        return '';
    }
  }

  // ------------------------------------------------------------- Build
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8F2), Color(0xFFFDEFEA)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'إنشاء حساب جديد',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildBasicInfo(),
                    const SizedBox(height: 16),
                    _buildStudyCard(),
                    const SizedBox(height: 16),
                    _buildConfessor(),
                    const SizedBox(height: 16),
                    _buildPasswordCard(),
                    // const SizedBox(height: 14),
                    // _buildNotificationsCard(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildLoginLink(),
                    const SizedBox(height: 18),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- Top bar
  Widget _buildTopBar() {
    return Row(
      children: [
        // Back button (right side in RTL)


        Text(
          'اجتماع الملاك غبريال',
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: (){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context){
                  return LoginPage();
                })
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Icon(
              Icons.arrow_forward,
              color: AppColors.burgundy,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------- Name + phone
  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('الاسم بالكامل (رباعي)', required: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          style: _inputStyle(),
          decoration: _decoration(
            hint: 'مثال: بيتر ميخائيل حنا يوسف',
            icon: Icons.person_outline,
            fill: Colors.white,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'من فضلك أدخل الاسم';
            if (v.trim().split(RegExp(r'\s+')).length < 4) {
              return 'من فضلك أدخل الاسم رباعي';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label(
          'رقم الهاتف والواتساب',
          required: true,
          trailing: 'مهم للتواصل والتنبيهات',
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: _inputStyle(),
          decoration: _decoration(
            hint: '0123 456 7890',
            icon: Icons.smartphone_outlined,
            fill: Colors.white,
          ),
          validator: (v) {
            final digits = (v ?? '').replaceAll(RegExp(r'\s'), '');
            if (digits.isEmpty) return 'من فضلك أدخل رقم الهاتف';
            if (digits.length < 10) return 'رقم الهاتف غير صحيح';
            return null;
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------- Study card
  Widget _buildStudyCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(icon: Icons.school, title: 'المرحلة والدراسة الجامعية'),
          const SizedBox(height: 16),
          _label('الجامعة والكلية', required: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _universityController,
            textInputAction: TextInputAction.next,
            style: _inputStyle(),
            decoration: _decoration(
              hint: 'مثال: جامعة القاهرة - كلية الهندسة',
              icon: Icons.account_balance_outlined, fill:AppColors.fieldFill,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'من فضلك أدخل الجامعة والكلية'
                : null,
          ),
          const SizedBox(height: 14),
          _label('الفرقة / السنة الدراسية', required: true),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _studyYear,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.hint),
            borderRadius: BorderRadius.circular(14),
            dropdownColor: Colors.white,
            style: _inputStyle(),
            decoration: _decoration(
              hint: 'اختر السنة الدراسية',
              icon: Icons.calendar_today_outlined, fill: AppColors.fieldFill,
            ),
            items: _studyYears
                .map((y) => DropdownMenuItem(
              value: y,
              child: Text(y, style: _inputStyle()),
            ))
                .toList(),
            onChanged: (v) => setState(() => _studyYear = v),
            validator: (v) => v == null ? 'من فضلك اختر السنة الدراسية' : null,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------- Father of confession
  Widget _buildConfessor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.church_outlined,
                color: AppColors.burgundy, size: 20),
            const SizedBox(width: 6),
            Text(
              'أب الاعتراف',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confessorController,
          textInputAction: TextInputAction.next,
          style: _inputStyle(),
          decoration: _decoration(
            hint: 'مثال: أبونا غبريال',
            icon: Icons.menu_book_outlined,
            fill: Colors.white,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------- Password card
  Widget _buildPasswordCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.lock_person_outlined,
            title: 'كلمة المرور وحماية الحساب',
            trailing: '٦ أحرف كحد أدنى',
          ),
          const SizedBox(height: 16),
          _label('كلمة المرور', required: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: _inputStyle(),
            onChanged: (_) => setState(() {}),
            decoration: _decoration(
              hint: '••••••••',
              icon: Icons.vpn_key_outlined,
              suffix: _eyeButton(
                obscure: _obscurePassword,
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ), fill: AppColors.fieldFill,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'من فضلك أدخل كلمة المرور';
              if (v.length < 6) return 'كلمة المرور يجب ألا تقل عن ٦ أحرف';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildStrengthMeter(),
          const SizedBox(height: 14),
          _label('تأكيد كلمة المرور', required: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: _inputStyle(),
            decoration: _decoration(
              hint: '••••••••',
              icon: Icons.check_circle_outline,
              suffix: _eyeButton(
                obscure: _obscureConfirm,
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ), fill: AppColors.fieldFill,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'من فضلك أكد كلمة المرور';
              if (v != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthMeter() {
    final strength = _passwordStrength(_passwordController.text);
    return Column(
      children: [
        Row(
          children: [
            Text(
              'قوة كلمة المرور:',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              _strengthLabel(strength),
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            final filled = i < strength;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsetsDirectional.only(end: i == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: filled ? AppColors.gold : AppColors.fieldBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // -------------------------------------------------- Notifications card
  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _acceptNotifications,
              activeColor: AppColors.burgundy,
              side: BorderSide(color: AppColors.fieldBorder, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (v) =>
                  setState(() => _acceptNotifications = v ?? false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أوافق على استلام تنبيهات ومواعيد الاجتماعات والأنشطة الروحية',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'رسائل الخدمة المباشرة عبر تطبيق الواتساب',
                  style: GoogleFonts.tajawal(
                    fontSize: 10.5,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------- Submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.burgundy.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1, size: 20),
            const SizedBox(width: 8),
            GestureDetector(
              onTap:
              (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return Bottombar();
                  })
                );
              },
              child: Text(
                'تسجيل حساب جديد',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لديك حساب بالفعل ؟',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap:
                () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return LoginPage();
                  })
              );
            },
            child: Text(
              'تسجيل الدخول',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.burgundy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: AppColors.gold, size: 15),
              const SizedBox(width: 6),
              Text(
                '• اجتماع الملاك غبريال الجامعي',
                style: GoogleFonts.tajawal(
                  fontSize: 10.5,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'اجتماع جامعيين © 2026',
            style: GoogleFonts.tajawal(
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ Helpers
  TextStyle _inputStyle() => GoogleFonts.tajawal(
    fontSize: 13.5,
    color: AppColors.textDark,
  );

  Widget _label(String text, {bool required = false, String? trailing}) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            text: text,
            style: GoogleFonts.tajawal(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.tajawal(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.burgundy,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing,
            style: GoogleFonts.tajawal(
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    String? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.burgundy, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing,
            style: GoogleFonts.tajawal(
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _eyeButton({required bool obscure, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.hint,
        size: 21,
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix, required Color fill,
    // Color fill = AppColors.fieldFill,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: 1.2),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.hint),
      errorStyle: GoogleFonts.tajawal(fontSize: 11),
      filled: true,
      fillColor: fill,
      prefixIcon: Icon(icon, color: AppColors.hint, size: 22),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: border(AppColors.fieldBorder),
      enabledBorder: border(AppColors.fieldBorder),
      focusedBorder: border(AppColors.burgundy),
      errorBorder: border(Colors.red.shade300),
      focusedErrorBorder: border(Colors.red.shade400),
    );
  }
}

/// White rounded card used for the grouped sections.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}