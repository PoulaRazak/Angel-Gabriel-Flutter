import 'package:angel_gabriel/core/resources/app-images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/app-colors.dart';
import '../signup/view.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Force RTL + Arabic
      locale: const Locale('ar'),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: ThemeData(
        useMaterial3: true,
        // Applies Tajawal to every default text style in the app
        textTheme: GoogleFonts.tajawalTextTheme(),
        primaryTextTheme: GoogleFonts.tajawalTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // TODO: add your login logic
  }

  void _biometricLogin() {
    // TODO: add your fingerprint / Face ID logic
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl,
        child:
      Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F2), Color(0xFFFDEFEA)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildTopBar(),
                          const SizedBox(height: 24),
                          _buildLogo(),
                          const SizedBox(height: 16),
                          _buildWelcome(),
                          const SizedBox(height: 22),
                          _buildFormCard(),
                          const SizedBox(height: 16),
                          const SizedBox(height: 24),
                          _buildRegisterPill(),
                          const SizedBox(height: 14),
                          _buildFooter(),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }

  // ---------------------------------------------------------------- Top bar
  Widget _buildTopBar() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'كنيسة العذراء والملاك غبريال - جامعيين',
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------- Logo
  Widget _buildLogo() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        // TODO: put your logo here, for example:
        child: Image.asset(
            AppImages.Applogo
            , fit: BoxFit.cover),
        // child: const SizedBox.expand(),
      ),
    );
  }

  // ---------------------------------------------------------------- Welcome
  Widget _buildWelcome() {
    return Column(
      children: [
        Text(
          'مرحباً بك مجدداً',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اجتماع الملاك غبريال الجامعي',
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- Form card
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('رقم الهاتف'),
          const SizedBox(height: 8),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _label('كلمة المرور'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 10),
          _buildRememberMe(),
          const SizedBox(height: 14),
          _buildLoginButton(),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'أو تسجيل الدخول السريع عبر البصمة',
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildBiometricButton(),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: 1.2),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(
        fontSize: 13,
        color: AppColors.hint,
      ),
      filled: true,
      fillColor: AppColors.fieldFill,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: border(AppColors.fieldBorder),
      focusedBorder: border(AppColors.burgundy),
      border: border(AppColors.fieldBorder),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textDark),
      decoration: _fieldDecoration(
        hint: 'أدخل رقم الهاتف ..',
        prefixIcon: Icon(
          Icons.contact_phone_outlined,
          color: AppColors.hint,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscure,
      style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textDark),
      decoration: _fieldDecoration(
        hint: '••••••••',
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppColors.hint,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.hint,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _remember,
            activeColor: AppColors.burgundy,
            side: BorderSide(color: AppColors.fieldBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (v) => setState(() => _remember = v ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'تذكرني',
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.burgundy.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 20),
            const SizedBox(width: 8),
            Text(
              'تسجيل الدخول',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _biometricLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.fieldFill,
          side: BorderSide(color: AppColors.fieldBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: AppColors.gold, size: 24),
            const SizedBox(width: 8),
            Text(
              'بصمة الإصبع / Face ID',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------- Register pill
  Widget _buildRegisterPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ليس لديك حساب ؟',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap:
                () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return SignUpPage();
                  })
              );
            },
            child: Text(
              'إنشاء حساب جديد',
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

  // ----------------------------------------------------------------- Footer
  Widget _buildFooter() {
    return Text(
      ' اجتماع جامعيين © 2026',
      textAlign: TextAlign.center,
      style: GoogleFonts.tajawal(
        fontSize: 10,
        color: AppColors.textGrey,
      ),
    );
  }
}