import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Your external colors file (class AppColors).
import '../../../../core/resources/app-colors.dart';

/* ========================================================================== */
/*  MODELS  (shape these to match your API)                                   */
/* ========================================================================== */

/// Used only to pick the icon of each meeting.
/// Map your API's meeting type to one of these values.
enum MeetingType { youth, bible, prayer, mass, other }

class AttendanceEntry {
  final String id;
  final String title; // e.g. "اجتماع الشباب الأسبوعي"
  final String dateLabel; // e.g. "الجمعة 27 أكتوبر 2023"
  final String timeLabel; // e.g. "07:15 PM"
  final bool isPresent; // true = حاضر, false = غائب
  final MeetingType type;

  const AttendanceEntry({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.isPresent,
    this.type = MeetingType.other,
  });
}

class AttendanceMonthData {
  final int totalCount; // إجمالي اللقاءات
  final int presentCount; // مرات الحضور
  final int absentCount; // مرات الغياب
  final int percent; // نسبة الشهر 0..100
  final List<AttendanceEntry> entries;

  const AttendanceMonthData({
    required this.totalCount,
    required this.presentCount,
    required this.absentCount,
    required this.percent,
    required this.entries,
  });

  /// PLACEHOLDER DATA so the UI is visible before the API is connected.
  /// Delete this once your real API is ready.
  factory AttendanceMonthData.placeholder() => const AttendanceMonthData(
    totalCount: 8,
    presentCount: 7,
    absentCount: 1,
    percent: 88,
    entries: [
      AttendanceEntry(
        id: '1',
        title: 'اجتماع الشباب الأسبوعي',
        dateLabel: 'الجمعة 27 أكتوبر 2023',
        timeLabel: '07:15 PM',
        isPresent: true,
        type: MeetingType.youth,
      ),
      AttendanceEntry(
        id: '2',
        title: 'درس كتاب المساء',
        dateLabel: 'الثلاثاء 24 أكتوبر 2023',
        timeLabel: '06:30 PM',
        isPresent: true,
        type: MeetingType.bible,
      ),
      AttendanceEntry(
        id: '3',
        title: 'اجتماع الصلاة والتسبيح',
        dateLabel: 'الجمعة 20 أكتوبر 2023',
        timeLabel: '07:00 PM',
        isPresent: false,
        type: MeetingType.prayer,
      ),
      AttendanceEntry(
        id: '4',
        title: 'درس كتاب المساء',
        dateLabel: 'الثلاثاء 17 أكتوبر 2023',
        timeLabel: '06:30 PM',
        isPresent: true,
        type: MeetingType.bible,
      ),
      AttendanceEntry(
        id: '5',
        title: 'قداس الجمعة الصباحي',
        dateLabel: 'الجمعة 13 أكتوبر 2023',
        timeLabel: '08:00 AM',
        isPresent: true,
        type: MeetingType.mass,
      ),
      AttendanceEntry(
        id: '6',
        title: 'درس كتاب المساء',
        dateLabel: 'الثلاثاء 10 أكتوبر 2023',
        timeLabel: '06:30 PM',
        isPresent: true,
        type: MeetingType.bible,
      ),
      AttendanceEntry(
        id: '7',
        title: 'اجتماع الشباب الأسبوعي',
        dateLabel: 'الجمعة 6 أكتوبر 2023',
        timeLabel: '07:15 PM',
        isPresent: true,
        type: MeetingType.youth,
      ),
      AttendanceEntry(
        id: '8',
        title: 'درس كتاب المساء',
        dateLabel: 'الثلاثاء 3 أكتوبر 2023',
        timeLabel: '06:30 PM',
        isPresent: true,
        type: MeetingType.bible,
      ),
    ],
  );
}

/* ========================================================================== */
/*  API SERVICE  (empty on purpose: put your API logic here)                  */
/* ========================================================================== */

class AttendanceHistoryService {
  /// Load the attendance summary and records for one month.
  Future<AttendanceMonthData> fetchMonth(int year, int month) async {
    // TODO: call your API here and parse the response, for example:
    //
    // final response = await dio.get(
    //   '/attendance',
    //   queryParameters: {'year': year, 'month': month},
    // );
    // return AttendanceMonthData.fromJson(response.data);

    // Temporary placeholder so the screen renders. Remove when API is ready.
    await Future.delayed(const Duration(milliseconds: 400));
    return AttendanceMonthData.placeholder();
  }
}

/* ========================================================================== */
/*  EXTRA COLORS (not in your AppColors) + TEXT HELPER                        */
/* ========================================================================== */

class _AC {
  static const success = Color(0xFF2E9E5B);
  static const successBg = Color(0xFFE3F6EA);
  static const danger = Color(0xFFD64545);
  static const dangerBg = Color(0xFFFCE8E8);
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

const _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

String _monthLabel(DateTime d) => '${_arabicMonths[d.month - 1]} ${d.year}';

enum _Filter { all, present, absent }

/* ========================================================================== */
/*  ATTENDANCE PAGE                                                           */
/*  Returns only the page content (no Scaffold), so you can place it inside   */
/*  your own Scaffold / tab view that already has the bottom bar.             */
/* ========================================================================== */

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _service = AttendanceHistoryService();

  late DateTime _selectedMonth;
  _Filter _filter = _Filter.all;

  AttendanceMonthData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _loadMonth();
  }

  // ------------------------------------------------------------ API calls
  Future<void> _loadMonth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service
          .fetchMonth(_selectedMonth.year, _selectedMonth.month);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل السجل، حاول مرة أخرى';
        _loading = false;
      });
    }
  }

  // -------------------------------------------------------------- Actions
  Future<void> _pickMonth() async {
    final now = DateTime.now();
    // Last 12 months, newest first.
    final months = List.generate(12, (i) => DateTime(now.year, now.month - i));

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.fieldBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Text('اختر الشهر',
                  style: _t(16, weight: FontWeight.w800, color: AppColors.burgundy)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: months.map((m) {
                    final selected = m.year == _selectedMonth.year &&
                        m.month == _selectedMonth.month;
                    return ListTile(
                      onTap: () => Navigator.pop(ctx, m),
                      title: Text(
                        _monthLabel(m),
                        style: _t(14,
                            weight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected
                                ? AppColors.burgundy
                                : AppColors.textDark),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check_circle,
                          color: AppColors.burgundy)
                          : null,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (picked == null) return;
    if (picked.year == _selectedMonth.year &&
        picked.month == _selectedMonth.month) {
      return;
    }
    setState(() {
      _selectedMonth = picked;
      _filter = _Filter.all;
    });
    _loadMonth();
  }

  void _onEntryTap(AttendanceEntry entry) {
    // TODO: (optional) open the details of this attendance record.
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
          child: SafeArea(
            child: RefreshIndicator(
              color: AppColors.burgundy,
              onRefresh: _loadMonth,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  Text('سجل الحضور والغياب',
                      style: _t(23,
                          weight: FontWeight.w800, color: AppColors.burgundy)),
                  const SizedBox(height: 14),
                  ..._buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_loading) {
      return const [
        SizedBox(height: 80),
        Center(child: CircularProgressIndicator(color: AppColors.burgundy)),
      ];
    }

    if (_data == null) {
      return [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Text(_error ?? 'حدث خطأ',
                  style: _t(13, color: AppColors.textGrey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadMonth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                ),
                child: Text('إعادة المحاولة',
                    style:
                    _t(13, weight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ),
      ];
    }

    final data = _data!;
    final presentCount = data.entries.where((e) => e.isPresent).length;
    final absentCount = data.entries.length - presentCount;

    final visible = data.entries.where((e) {
      switch (_filter) {
        case _Filter.present:
          return e.isPresent;
        case _Filter.absent:
          return !e.isPresent;
        case _Filter.all:
          return true;
      }
    }).toList();

    return [
      _SummaryCard(data: data, monthLabel: _monthLabel(_selectedMonth)),
      const SizedBox(height: 16),
      _buildFilterTabs(
        all: data.entries.length,
        present: presentCount,
        absent: absentCount,
      ),
      const SizedBox(height: 14),
      if (visible.isEmpty)
        _buildEmpty()
      else
        ...visible.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EntryCard(entry: e, onTap: () => _onEntryTap(e)),
          ),
        ),
    ];
  }

  // --------------------------------------------------------------- Top bar
  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.church, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text('الملاك غبريال',
            style: _t(15, weight: FontWeight.w800, color: AppColors.burgundy)),
        const Spacer(),
        InkWell(
          onTap: _pickMonth,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.fieldFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month_outlined,
                    color: AppColors.burgundy, size: 18),
                const SizedBox(width: 6),
                Text(_monthLabel(_selectedMonth),
                    style: _t(12, weight: FontWeight.w800)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textGrey, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- Filter tabs
  Widget _buildFilterTabs({
    required int all,
    required int present,
    required int absent,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fieldFill.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          _FilterTab(
            label: 'الكل',
            count: all,
            icon: Icons.view_list_outlined,
            iconColor: AppColors.textGrey,
            chipBg: AppColors.fieldBorder,
            chipFg: AppColors.textDark,
            selected: _filter == _Filter.all,
            onTap: () => setState(() => _filter = _Filter.all),
          ),
          _FilterTab(
            label: 'حاضر',
            count: present,
            icon: Icons.check_circle_outline,
            iconColor: _AC.success,
            chipBg: _AC.successBg,
            chipFg: _AC.success,
            selected: _filter == _Filter.present,
            onTap: () => setState(() => _filter = _Filter.present),
          ),
          _FilterTab(
            label: 'غائب',
            count: absent,
            icon: Icons.cancel_outlined,
            iconColor: _AC.danger,
            chipBg: _AC.dangerBg,
            chipFg: _AC.danger,
            selected: _filter == _Filter.absent,
            onTap: () => setState(() => _filter = _Filter.absent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined,
              size: 42, color: AppColors.hint.withOpacity(0.9)),
          const SizedBox(height: 10),
          Text('لا توجد سجلات في هذا القسم',
              style: _t(13, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/*  WIDGETS                                                                   */
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

/* ------------------------------------------------------------ Summary card */
class _SummaryCard extends StatelessWidget {
  final AttendanceMonthData data;
  final String monthLabel;

  const _SummaryCard({required this.data, required this.monthLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(radius: 20),
      child: Column(
        children: [
          // Top gradient strip
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.burgundy, AppColors.gold, _AC.success],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('ملخص $monthLabel',
                          style: _t(16,
                              weight: FontWeight.w800,
                              color: AppColors.burgundy)),
                    ),
                    _ring(),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'إجمالي اللقاءات',
                        value: '${data.totalCount}',
                        unit: 'اجتماعات',
                        labelColor: AppColors.textGrey,
                        valueColor: AppColors.textDark,
                        unitColor: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                        label: 'مرات الحضور',
                        value: '${data.presentCount}',
                        unit: 'حاضر',
                        labelColor: AppColors.textGrey,
                        valueColor: AppColors.textDark,
                        unitColor: _AC.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                        label: 'مرات الغياب',
                        value: '${data.absentCount}',
                        unit: 'غائب',
                        labelColor: _AC.danger,
                        valueColor: _AC.danger,
                        unitColor: _AC.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring() {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (data.percent / 100).clamp(0.0, 1.0),
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: _AC.successBg,
              valueColor: const AlwaysStoppedAnimation<Color>(_AC.success),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${data.percent}%',
                  style: _t(17, weight: FontWeight.w800)),
              Text('نسبة الشهر',
                  style: _t(8.5, color: AppColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color labelColor;
  final Color valueColor;
  final Color unitColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.labelColor,
    required this.valueColor,
    required this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.fieldFill.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.7)),
      ),
      child: Column(
        children: [
          Text(label,
              style: _t(9.5, weight: FontWeight.w700, color: labelColor)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: _t(20, weight: FontWeight.w800, color: valueColor)),
              const SizedBox(width: 4),
              Text(unit,
                  style: _t(10, weight: FontWeight.w700, color: unitColor)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------ Filter tab */
class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
  final Color chipBg;
  final Color chipFg;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.chipBg,
    required this.chipFg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: _t(11.5,
                        weight: FontWeight.w800,
                        color: selected
                            ? AppColors.textDark
                            : AppColors.textGrey)),
                const SizedBox(width: 5),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$count',
                      style: _t(10, weight: FontWeight.w800, color: chipFg)),
                ),
                const SizedBox(width: 5),
                Icon(icon, size: 15, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------- Entry card */
class _EntryCard extends StatelessWidget {
  final AttendanceEntry entry;
  final VoidCallback onTap;

  const _EntryCard({required this.entry, required this.onTap});

  IconData get _icon {
    switch (entry.type) {
      case MeetingType.youth:
        return Icons.groups_outlined;
      case MeetingType.bible:
        return Icons.menu_book_outlined;
      case MeetingType.prayer:
        return Icons.volunteer_activism_outlined;
      case MeetingType.mass:
        return Icons.church_outlined;
      case MeetingType.other:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final present = entry.isPresent;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(radius: 16),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meeting icon (right side)
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: present ? AppColors.fieldFill : _AC.dangerBg,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _icon,
                      size: 24,
                      color: present ? AppColors.burgundy : _AC.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title,
                            style: _t(15, weight: FontWeight.w800, height: 1.3)),
                        const SizedBox(height: 6),
                        _meta(Icons.calendar_today_outlined, entry.dateLabel),
                        const SizedBox(height: 3),
                        _meta(Icons.access_time, entry.timeLabel),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusChip(present),
                ],
              ),
            ),
          ),
          // Red accent bar for absent records (right edge in RTL)
          if (!present)
            const PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              child: SizedBox(
                width: 4,
                child: ColoredBox(color: _AC.danger),
              ),
            ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textGrey),
        const SizedBox(width: 5),
        Text(text, style: _t(10.5, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _statusChip(bool present) {
    final fg = present ? _AC.success : _AC.danger;
    final bg = present ? _AC.successBg : _AC.dangerBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(present ? 'حاضر' : 'غائب',
              style: _t(10.5, weight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }
}