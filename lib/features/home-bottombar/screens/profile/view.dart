import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Your external colors file (class AppColors).
import '../../../../core/resources/app-colors.dart';

/* ========================================================================== */
/*  MODELS  (shape these to match your API)                                   */
/* ========================================================================== */

class ProfileData {
  final String fullName;
  final String phone;
  final String university; // الجامعة والكلية
  final String studyYear; // الفرقة الدراسية
  final String confessor; // أب الاعتراف

  const ProfileData({
    required this.fullName,
    required this.phone,
    required this.university,
    required this.studyYear,
    required this.confessor,
  });

  /// PLACEHOLDER DATA so the UI is visible before the API is connected.
  /// Delete this once your real API is ready.
  factory ProfileData.placeholder() => const ProfileData(
    fullName: 'بيتر ميخائيل حنا يوسف',
    phone: '0123 456 7890',
    university: 'جامعة القاهرة - كلية الهندسة',
    studyYear: 'الفرقة الثالثة',
    confessor: 'أبونا غبريال',
  );
}

/* ========================================================================== */
/*  API SERVICE  (empty on purpose: put your API logic here)                  */
/* ========================================================================== */

class ProfileApiService {
  /// Load the current user's profile.
  Future<ProfileData> fetchProfile() async {
    // TODO: call your API here and parse the response into ProfileData.
    //
    // final response = await dio.get('/profile');
    // return ProfileData.fromJson(response.data);

    // Temporary placeholder so the screen renders. Remove when API is ready.
    await Future.delayed(const Duration(milliseconds: 400));
    return ProfileData.placeholder();
  }

  /// Save the edited profile.
  Future<ProfileData> updateProfile(ProfileData data) async {
    // TODO: call your update API here and return the saved profile.
    //
    // final response = await dio.put('/profile', data: data.toJson());
    // return ProfileData.fromJson(response.data);

    // Temporary placeholder. Remove when API is ready.
    await Future.delayed(const Duration(milliseconds: 600));
    return data;
  }

  /// Log the user out.
  Future<void> logout() async {
    // TODO: call your logout API, clear the saved token / local storage.
  }
}

/* ========================================================================== */
/*  EXTRA COLORS (not in your AppColors) + TEXT HELPER                        */
/* ========================================================================== */

class _PC {
  static const danger = Color(0xFFC62E3E);
  static const dangerBorder = Color(0xFFF0C4C8);
  static const success = Color(0xFF2E9E5B);
}

TextStyle _t(
    double size, {
      FontWeight weight = FontWeight.w500,
      Color color = AppColors.textDark,
      double? height,
    }) =>
    GoogleFonts.tajawal(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

/* ========================================================================== */
/*  PROFILE PAGE                                                              */
/*  Returns only the page content (no Scaffold), so you can place it inside   */
/*  your own Scaffold / tab view that already has the bottom bar.             */
/* ========================================================================== */

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _service = ProfileApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();
  final _confessorController = TextEditingController();

  // TODO: read the real version with the package_info_plus package.
  static const _appVersion = '2.1.1';

  final List<String> _studyYears = [
    'الفرقة الأولى',
    'الفرقة الثانية',
    'الفرقة الثالثة',
    'الفرقة الرابعة',
    'الفرقة الخامسة',
    'الفرقة السادسة',
    'خريج',
  ];

  ProfileData? _original; // last saved data (used by "cancel")
  String? _studyYear;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _confessorController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ API calls
  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchProfile();
      if (!mounted) return;
      _applyData(data);
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل البيانات، حاول مرة أخرى';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final saved = await _service.updateProfile(
        ProfileData(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          university: _universityController.text.trim(),
          studyYear: _studyYear ?? '',
          confessor: _confessorController.text.trim(),
        ),
      );
      if (!mounted) return;
      _applyData(saved);
      setState(() => _saving = false);
      _showMessage('تم حفظ التعديلات بنجاح', success: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('تعذر حفظ التعديلات، حاول مرة أخرى');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('تسجيل الخروج',
              style: _t(16, weight: FontWeight.w800, color: AppColors.burgundy)),
          content: Text('هل تريد تسجيل الخروج من حسابك؟',
              style: _t(13, color: AppColors.textGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء',
                  style: _t(13,
                      weight: FontWeight.w700, color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('تسجيل الخروج',
                  style:
                  _t(13, weight: FontWeight.w800, color: _PC.danger)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    // TODO: call the logout API, then navigate to the login page
    // (and clear the navigation stack).
    await _service.logout();
  }

  // -------------------------------------------------------------- Helpers
  void _applyData(ProfileData data) {
    _original = data;
    _nameController.text = data.fullName;
    _phoneController.text = data.phone;
    _universityController.text = data.university;
    _confessorController.text = data.confessor;

    if (data.studyYear.isNotEmpty && !_studyYears.contains(data.studyYear)) {
      _studyYears.add(data.studyYear);
    }
    _studyYear = data.studyYear.isEmpty ? null : data.studyYear;
  }

  void _resetChanges() {
    final data = _original;
    if (data == null) return;
    setState(() => _applyData(data));
    _formKey.currentState?.reset();
    _showMessage('تم التراجع عن التغييرات', success: true);
  }

  void _showMessage(String text, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? _PC.success : AppColors.burgundy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(text,
                style: _t(12.5, weight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      );
  }

  // ---------------------------------------------------------------- Build
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8F2), Color(0xFFFDEFEA)],
            ),
          ),
          child: SafeArea(child: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.burgundy),
      );
    }

    if (_original == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'حدث خطأ', style: _t(13, color: AppColors.textGrey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
              ),
              child: Text('إعادة المحاولة',
                  style: _t(13, weight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 14),
          _buildPersonalCard(),
          const SizedBox(height: 14),
          _buildStudyCard(),
          const SizedBox(height: 14),
          _buildSpiritualCard(),
          const SizedBox(height: 20),
          _buildSaveButton(),
          const SizedBox(height: 10),
          _buildCancelButton(),
          const SizedBox(height: 22),
          _buildLogoutButton(),
          const SizedBox(height: 10),
          Center(
            child: Text('إصدار التطبيق $_appVersion',
                style: _t(10, color: AppColors.textGrey)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- Header card
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(radius: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.burgundy.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.badge_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _original!.fullName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _t(17, weight: FontWeight.w800, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- Sections
  Widget _buildPersonalCard() {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'البيانات الشخصية',
      chip: 'أساسي',
      children: [
        _label('الاسم بالكامل رباعي'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          style: _inputStyle(),
          decoration: _decoration(icon: Icons.edit_outlined),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'من فضلك أدخل الاسم';
            if (v.trim().split(RegExp(r'\s+')).length < 4) {
              return 'من فضلك أدخل الاسم رباعي';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _label('رقم الهاتف والواتساب'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: _inputStyle(),
          decoration: _decoration(icon: Icons.smartphone_outlined),
          validator: (v) {
            final digits = (v ?? '').replaceAll(RegExp(r'\s'), '');
            if (digits.isEmpty) return 'من فضلك أدخل رقم الهاتف';
            if (digits.length < 10) return 'رقم الهاتف غير صحيح';
            return null;
          },
        ),
        const SizedBox(height: 6),
        Text('يُستخدم هذا الرقم لإرسال تنبيهات الأنشطة والافتقاد',
            style: _t(10, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildStudyCard() {
    return _SectionCard(
      icon: Icons.school_outlined,
      title: 'البيانات الدراسية والجامعية',
      chip: 'دراسة',
      children: [
        _label('الجامعة والكلية'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _universityController,
          textInputAction: TextInputAction.next,
          style: _inputStyle(),
          decoration: _decoration(icon: Icons.apartment_outlined),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'من فضلك أدخل الجامعة والكلية'
              : null,
        ),
        const SizedBox(height: 14),
        _label('الفرقة الدراسية'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _studyYear,
          isExpanded: true,
          icon: Icon(Icons.unfold_more, color: AppColors.hint, size: 20),
          borderRadius: BorderRadius.circular(14),
          dropdownColor: Colors.white,
          style: _inputStyle(),
          decoration: _decoration(),
          items: _studyYears
              .map((y) => DropdownMenuItem(
            value: y,
            child: Text(y, style: _inputStyle()),
          ))
              .toList(),
          onChanged: (v) => setState(() => _studyYear = v),
          validator: (v) => v == null ? 'من فضلك اختر الفرقة الدراسية' : null,
        ),
      ],
    );
  }

  Widget _buildSpiritualCard() {
    return _SectionCard(
      icon: Icons.church_outlined,
      title: 'الرعاية الروحية',
      children: [
        _label('أب الاعتراف'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confessorController,
          textInputAction: TextInputAction.done,
          style: _inputStyle(),
          decoration: _decoration(icon: Icons.volunteer_activism_outlined),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- Buttons
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          disabledBackgroundColor: AppColors.burgundy.withOpacity(0.7),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.burgundy.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _saving
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('حفظ التعديلات',
                style: _t(14,
                    weight: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_outline, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: _saving ? null : _resetChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fieldFill,
          foregroundColor: AppColors.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: AppColors.fieldBorder),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('إلغاء التغييرات والتراجع',
                style: _t(12,
                    weight: FontWeight.w700, color: AppColors.textGrey)),
            const SizedBox(width: 8),
            Icon(Icons.restart_alt, size: 18, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: _PC.dangerBorder, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('تسجيل الخروج من الحساب',
                style: _t(13, weight: FontWeight.w800, color: _PC.danger)),
            const SizedBox(width: 8),
            const Icon(Icons.logout, size: 19, color: _PC.danger),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- Fields
  TextStyle _inputStyle() => _t(13.5, weight: FontWeight.w600);

  Widget _label(String text) =>
      Text(text, style: _t(11, weight: FontWeight.w700));

  InputDecoration _decoration({IconData? icon}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: 1.2),
    );

    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      errorStyle: _t(11, color: Colors.red.shade400),
      suffixIcon:
      icon == null ? null : Icon(icon, color: AppColors.textGrey, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
      border: border(AppColors.fieldBorder),
      enabledBorder: border(AppColors.fieldBorder),
      focusedBorder: border(AppColors.burgundy),
      errorBorder: border(Colors.red.shade300),
      focusedErrorBorder: border(Colors.red.shade400),
    );
  }
}

/* ========================================================================== */
/*  SHARED WIDGETS                                                            */
/* ========================================================================== */

BoxDecoration _cardDecoration({double radius = 18}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.fieldBorder.withOpacity(0.7)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ],
);

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? chip;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.chip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.burgundy, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: _t(14.5, weight: FontWeight.w800)),
              ),
              if (chip != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: Text(chip!,
                      style: _t(9.5,
                          weight: FontWeight.w700, color: AppColors.textGrey)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: AppColors.fieldBorder.withOpacity(0.8),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}