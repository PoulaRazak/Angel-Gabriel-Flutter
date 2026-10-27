import 'package:angel_gabriel/features/home-bottombar/screens/attendance/view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/app-colors.dart';

/* ========================================================================== */
/*  MODELS  (shape these to match your API response)                          */
/* ========================================================================== */

class HomeData {
  final String userName;
  final String monthLabel; // e.g. "شهر أكتوبر ٢٠٢٣"
  final int attendancePercent; // 0..100
  final String ratingLabel; // e.g. "ممتاز جداً"
  final int attendedCount; // meetings attended this month
  final int totalCount; // total meetings this month
  final int confirmedCount; // حضور مؤكد
  final int excusedCount; // غياب بعذر
  final int streakWeeks; // تتابع مستمر
  final String verse;
  final AttendanceRecord? lastAttendance;
  final NextMeeting? nextMeeting;

  const HomeData({
    required this.userName,
    required this.monthLabel,
    required this.attendancePercent,
    required this.ratingLabel,
    required this.attendedCount,
    required this.totalCount,
    required this.confirmedCount,
    required this.excusedCount,
    required this.streakWeeks,
    required this.verse,
    this.lastAttendance,
    this.nextMeeting,
  });

  /// PLACEHOLDER DATA so the UI is visible before the API is connected.
  /// Delete this once your real API is ready.
  factory HomeData.placeholder() => const HomeData(
    userName: 'مينا يوسف',
    monthLabel: 'شهر أكتوبر ٢٠٢٣',
    attendancePercent: 85,
    ratingLabel: 'ممتاز جداً',
    attendedCount: 6,
    totalCount: 7,
    confirmedCount: 6,
    excusedCount: 1,
    streakWeeks: 3,
    verse: '«طُوبَى لِمَنِ اخْتَرْتَهُ وَقَبِلْتَهُ لِيَسْكُنَ فِي دِيَارِكَ» (مز ٦٥: ٤)',
    lastAttendance: AttendanceRecord(
      title: 'اجتماع درس الكتاب الأسبوعي',
      dateLabel: 'الجمعة، 20 أكتوبر 2023',
      status: 'حاضر',
      sessionCode: '#402',
      timeLabel: '07:15 مساءً',
      confirmedBy: 'تأكيد خادم',
    ),
    nextMeeting: NextMeeting(
      title: 'صلاة التسبيحة والإعداد',
      dateTimeLabel: 'الجمعة 27 أكتوبر - 07:00 م',
    ),
  );
}

class AttendanceRecord {
  final String title;
  final String dateLabel;
  final String status; // حاضر / غائب ...
  final String sessionCode;
  final String timeLabel;
  final String confirmedBy;

  const AttendanceRecord({
    required this.title,
    required this.dateLabel,
    required this.status,
    required this.sessionCode,
    required this.timeLabel,
    required this.confirmedBy,
  });
}

class NextMeeting {
  final String title;
  final String dateTimeLabel;

  const NextMeeting({required this.title, required this.dateTimeLabel});
}

/* ========================================================================== */
/*  API SERVICE  (empty on purpose: put your API logic here)                  */
/* ========================================================================== */

class HomeApiService {
  /// Fetch everything the home screen needs.
  Future<HomeData> fetchHomeData() async {
    // TODO: call your API here (Dio / http), parse the response into HomeData.
    //
    // final response = await dio.get('/home');
    // return HomeData.fromJson(response.data);

    // Temporary placeholder so the screen renders. Remove when API is ready.
    await Future.delayed(const Duration(milliseconds: 400));
    return HomeData.placeholder();
  }

  /// Set a reminder for the next meeting.
  Future<void> setMeetingReminder() async {
    // TODO: call your reminder API here.
  }
}

/* ========================================================================== */
/*  EXTRA COLORS (only the ones that are not in your AppColors)               */
/*  Move them to AppColors if you prefer.                                     */
/* ========================================================================== */

class _HC {
  static final heroDark = Color.lerp(AppColors.burgundy, Colors.black, 0.35)!;
  static final goldLight = Color.lerp(AppColors.gold, Colors.white, 0.45)!;

  static const success = Color(0xFF2E9E5B);
  static const successLight = Color(0xFF6FD99A);
  static const successBg = Color(0xFFE6F5EC);
  static const danger = Color(0xFFD64545);
  static const dangerBg = Color(0xFFFCE8E8);
  static const flame = Color(0xFFE8852B);
  static const flameBg = Color(0xFFFDF0E2);
}

TextStyle _t(
    double size, {
      FontWeight weight = FontWeight.w500,
      Color color = Colors.white,
      double? height,
    }) =>
    GoogleFonts.tajawal(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

/* ========================================================================== */
/*  HOME SCREEN                                                               */
/*  Returns only the page content (no Scaffold / bottom bar), so you can      */
/*  place it inside your own Scaffold that already has the bottom bar.        */
/* ========================================================================== */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = HomeApiService();

  HomeData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // ------------------------------------------------------------ API calls
  Future<void> _loadHomeData() async {
    setState(() {
      _loading = _data == null;
      _error = null;
    });
    try {
      final data = await _service.fetchHomeData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل البيانات، حاول مرة أخرى';
        _loading = false;
      });
    }
  }

  // ------------------------------------------------------------- Actions
  void _onScanQr() {
    // TODO: open the QR scanner screen
  }

  void _onViewHistory() {
    // TODO: open the full attendance history screen
  }

  Future<void> _onRemindMe() async {
    // TODO: call _service.setMeetingReminder() and show feedback
    await _service.setMeetingReminder();
  }

  // --------------------------------------------------------------- Build
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
      return Center(
        child: CircularProgressIndicator(color: AppColors.burgundy),
      );
    }

    if (_data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'حدث خطأ', style: _t(13, color: AppColors.textGrey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadHomeData,
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

    final d = _data!;
    return RefreshIndicator(
      color: AppColors.burgundy,
      onRefresh: _loadHomeData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _WelcomeCard(name: d.userName),
          const SizedBox(height: 14),
          _MonthlyAttendanceCard(data: d),
          const SizedBox(height: 14),
          _StatsRow(data: d),
          const SizedBox(height: 14),
          _CheckInCard(onTap: _onScanQr),
          const SizedBox(height: 8),
          _qrHint(),
          const SizedBox(height: 18),
          _sectionHeader(),
          const SizedBox(height: 12),
          if (d.lastAttendance != null)
            _LastAttendanceCard(record: d.lastAttendance!),
          if (d.nextMeeting != null) ...[
            const SizedBox(height: 12),
            _NextMeetingCard(meeting: d.nextMeeting!, onRemind: _onRemindMe),
          ],
        ],
      ),
    );
  }

  Widget _qrHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: 14, color: AppColors.gold),
        const SizedBox(width: 5),
        Text(
          'يرجى توجيه الكاميرا نحو ال QR المعروض في قاعة الاجتماع',
          style: _t(10, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _sectionHeader() {
    return Row(
      children: [
        Icon(Icons.history, color: AppColors.burgundy, size: 22),
        const SizedBox(width: 6),
        Text('آخر حضور مسجل',
            style: _t(15, weight: FontWeight.w800, color: AppColors.burgundy)),
        const Spacer(),
        InkWell(
          onTap: _onViewHistory,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context){
                        return AttendancePage();
                      }
                    ));
                  },
                  child: Text('عرض السجل كاملاً',
                      style: _t(11,
                          weight: FontWeight.w700, color: AppColors.burgundy)),
                ),
                // chevron_right is mirrored in RTL, so it points left "<"
                Icon(Icons.chevron_right,
                    size: 18, color: AppColors.burgundy),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ========================================================================== */
/*  WIDGETS                                                                   */
/* ========================================================================== */

BoxDecoration _whiteCard({double radius = 18}) => BoxDecoration(
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

/* ------------------------------------------------------------ Welcome card */
class _WelcomeCard extends StatelessWidget {
  final String name;
  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _whiteCard(radius: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'أهلاً بك، $name',
                    overflow: TextOverflow.ellipsis,
                    style: _t(17,
                        weight: FontWeight.w800, color: AppColors.burgundy),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
              ],
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: _HC.goldLight,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------ Monthly attendance (hero) */
class _MonthlyAttendanceCard extends StatelessWidget {
  final HomeData data;
  const _MonthlyAttendanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.burgundy, _HC.heroDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.burgundy.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chip + month
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: _HC.goldLight, size: 14),
                    const SizedBox(width: 5),
                    Text('نسبة الحضور الشهرية',
                        style: _t(11,
                            weight: FontWeight.w700, color: Colors.white70)),
                  ],
                ),
              ),
              const Spacer(),
              Text(data.monthLabel,
                  style: _t(10.5,
                      weight: FontWeight.w700, color: _HC.goldLight)),
            ],
          ),
          const SizedBox(height: 16),

          // Percentage + ring
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${data.attendancePercent}%',
                            style: _t(34,
                                weight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(width: 8),
                        Text(data.ratingLabel,
                            style: _t(13,
                                weight: FontWeight.w700,
                                color: _HC.goldLight)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 15, color: _HC.successLight),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'حضرت ${data.attendedCount} من إجمالي ${data.totalCount} اجتماعات',
                            style: _t(11, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ProgressRing(percent: data.attendancePercent),
            ],
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
                height: 1, color: Colors.white.withOpacity(0.15), thickness: 1),
          ),

          // Verse
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: _HC.goldLight, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(data.verse,
                    style: _t(10.5,
                        weight: FontWeight.w500,
                        color: _HC.goldLight,
                        height: 1.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;
  const _ProgressRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_HC.goldLight),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _HC.goldLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded,
                color: AppColors.burgundy, size: 22),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------- Stats row */
class _StatsRow extends StatelessWidget {
  final HomeData data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            iconColor: _HC.success,
            iconBg: _HC.successBg,
            value: Text('${data.confirmedCount}',
                style: _t(24, weight: FontWeight.w800)),
            label: Text('حضور مؤكد',
                style: _t(11, weight: FontWeight.w500, color: AppColors.textGrey)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.event_busy_outlined,
            iconColor: _HC.danger,
            iconBg: _HC.dangerBg,
            value: Text('${data.excusedCount}',
                style: _t(24, weight: FontWeight.w800)),
            label: Text('غياب بعذر',
                style: _t(11, weight: FontWeight.w500, color: AppColors.textGrey)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: _HC.flame,
            iconBg: _HC.flameBg,
            value: Text.rich(
              TextSpan(
                text: '${data.streakWeeks} ',
                style: _t(24, weight: FontWeight.w800, color: AppColors.gold),
                children: [
                  TextSpan(
                    text: 'أسابيع',
                    style: _t(14,
                        weight: FontWeight.w800, color: AppColors.gold),
                  ),
                ],
              ),
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department,
                    size: 12, color: _HC.flame),
                const SizedBox(width: 2),
                Text('تتابع مستمر',
                    style: _t(11,
                        weight: FontWeight.w500, color: AppColors.textGrey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Widget value;
  final Widget label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: _whiteCard(radius: 16),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          value,
          const SizedBox(height: 2),
          label,
        ],
      ),
    );
  }
}

/* --------------------------------------------------- Check-in (QR) button */
class _CheckInCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CheckInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.burgundy, _HC.heroDark],
          ),
          border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.burgundy.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // QR icon box (right side)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.qr_code_scanner,
                      color: _HC.goldLight, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تسجيل الحضور الآن',
                          style: _t(16,
                              weight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('عبر مسح رمز QR للاستجابة السريع',
                          style: _t(10.5, color: Colors.white70)),
                    ],
                  ),
                ),
                // Arrow circle (left side). arrow_forward is mirrored in RTL.
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------- Last attendance record */
class _LastAttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const _LastAttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(radius: 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.menu_book_outlined,
                    color: AppColors.burgundy, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title,
                        style: _t(16, weight: FontWeight.w800, height: 1.35)),
                    const SizedBox(height: 4),
                    Text(record.dateLabel,
                        style: _t(11, color: AppColors.textGrey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(record.status),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: AppColors.fieldBorder.withOpacity(0.8),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _meta(Icons.tag, 'كود الجلسة: ${record.sessionCode}'),
              _meta(Icons.access_time, 'التوقيت: ${record.timeLabel}'),
              _meta(Icons.check_circle_outline, record.confirmedBy,
                  iconColor: _HC.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _HC.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: _HC.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(text,
              style: _t(11, weight: FontWeight.w800, color: _HC.success)),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text,
      {Color iconColor = Colors.white10}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 3),
        Text(text, style: _t(10, weight: FontWeight.w700)),
      ],
    );
  }
}

/* ------------------------------------------------------------ Next meeting */
class _NextMeetingCard extends StatelessWidget {
  final NextMeeting meeting;
  final VoidCallback onRemind;

  const _NextMeetingCard({required this.meeting, required this.onRemind});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_active_outlined,
                color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الاجتماع القادم: ${meeting.title}',
                    style: _t(12, weight: FontWeight.w800, height: 1.4)),
                const SizedBox(height: 3),
                Text(meeting.dateTimeLabel,
                    style: _t(10.5, color: AppColors.textGrey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onRemind,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.fieldBorder),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('تذكيرني',
                style: _t(11, weight: FontWeight.w800, color: AppColors.burgundy)),
          ),
        ],
      ),
    );
  }
}