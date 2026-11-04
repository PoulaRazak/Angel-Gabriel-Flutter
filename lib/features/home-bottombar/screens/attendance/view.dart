import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

enum AttendanceStatus { present, absent, excused, none }

class AttendanceRecordModel {
  final String id;
  final String title;
  final String sessionNumber;
  final DateTime date;
  final String? checkInTime;
  final String? note;
  final AttendanceStatus status;

  const AttendanceRecordModel({
    required this.id,
    required this.title,
    required this.sessionNumber,
    required this.date,
    this.checkInTime,
    this.note,
    required this.status,
  });

  static AttendanceStatus _parseStatus(String raw) {
    switch (raw) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.none;
    }
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final String rawDate = (json['date'] ?? '2026-11-01').toString();
    final DateTime parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    return AttendanceRecordModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      sessionNumber: (json['sessionNumber'] ?? '#401').toString(),
      date: parsedDate,
      checkInTime: json['checkInTime']?.toString(),
      note: json['note']?.toString(),
      status: _parseStatus((json['status'] ?? 'none').toString()),
    );
  }
}

class AttendanceStatsModel {
  final double attendanceRate;
  final int presentDaysCount;
  final int pointsCount;

  const AttendanceStatsModel({
    required this.attendanceRate,
    required this.presentDaysCount,
    required this.pointsCount,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsModel(
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      presentDaysCount: (json['presentDaysCount'] as num?)?.toInt() ?? 0,
      pointsCount: (json['pointsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MonthAttendanceData {
  final AttendanceStatsModel stats;
  final Map<int, AttendanceStatus> dayStatuses;
  final List<AttendanceRecordModel> records;

  const MonthAttendanceData({
    required this.stats,
    required this.dayStatuses,
    required this.records,
  });

  factory MonthAttendanceData.fromJson(Map<String, dynamic> json) {
    final rawDayStatuses =
        (json['dayStatuses'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<int, AttendanceStatus> mappedDays = <int, AttendanceStatus>{};
    rawDayStatuses.forEach((key, value) {
      final int? dayInt = int.tryParse(key);
      if (dayInt != null) {
        mappedDays[dayInt] = AttendanceRecordModel._parseStatus(value.toString());
      }
    });

    final rawRecords = (json['records'] as List<dynamic>?) ?? [];
    return MonthAttendanceData(
      stats: AttendanceStatsModel.fromJson(
        (json['stats'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      dayStatuses: mappedDays,
      records: rawRecords
          .map((e) => AttendanceRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttendanceHistoryService {
  Future<MonthAttendanceData> fetchMonthData(int year, int month) async {
    final json = await ApiClient.get(
      '/attendance',
      queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      },
    );
    return MonthAttendanceData.fromJson(json);
  }
}

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  static const Color primaryMaroon = Color(0xFF7A1C24);
  static const Color bgCream = Color(0xFFFAF6F0);
  static const Color cardSand = Color(0xFFF3ECE4);
  static const Color accentGold = Color(0xFFD69E2E);
  static const Color presentGreen = Color(0xFF2E6F40);
  static const Color absentRed = Color(0xFFC53030);
  static const Color textDark = Color(0xFF2D2320);
  static const Color textMuted = Color(0xFF7D6E68);

  final AttendanceHistoryService _service = AttendanceHistoryService();

  late DateTime _currentMonth;
  late int _selectedDay;
  bool _isLoading = true;
  MonthAttendanceData? _monthData;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDay = now.day;
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchMonthData(
        _currentMonth.year,
        _currentMonth.month,
      );
      if (mounted) {
        setState(() {
          _monthData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
      );
      _selectedDay = 1;
    });
    _loadMonthData();
  }

  String _getArabicMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCream,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryMaroon),
              )
            : RefreshIndicator(
                color: primaryMaroon,
                onRefresh: _loadMonthData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      _buildStatsHeader(),
                      const SizedBox(height: 24),
                      _buildCalendarCard(),
                      const SizedBox(height: 28),
                      _buildDetailsHeader(),
                      const SizedBox(height: 12),
                      _buildRecordsList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final stats = _monthData?.stats;
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          flex: 11,
          child: Container(
            height: 115,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B222C), Color(0xFF63131A)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'معدل الحضور العام',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stats.attendanceRate.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const Icon(
                      Icons.trending_up_rounded,
                      color: accentGold,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: _buildSmallStatCard(
            label: 'أيام الحضور',
            value: '${stats.presentDaysCount}',
            unit: 'يوم',
            valueColor: primaryMaroon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: _buildSmallStatCard(
            label: 'النقاط',
            value: '${stats.pointsCount}',
            unit: 'نقطة',
            valueColor: accentGold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      height: 115,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final int daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );

    final int startOffset = firstDayOfMonth.weekday % 7;

    const weekDays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: primaryMaroon,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_getArabicMonthName(_currentMonth.month)} ${_toArabicNumbers(_currentMonth.year.toString())}',
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildMonthNavBtn(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _changeMonth(-1),
                  ),
                  const SizedBox(width: 8),
                  _buildMonthNavBtn(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _changeMonth(1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + startOffset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }
              final int dayNumber = index - startOffset + 1;
              final AttendanceStatus status =
                  _monthData?.dayStatuses[dayNumber] ?? AttendanceStatus.none;
              final bool isSelected = dayNumber == _selectedDay;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = dayNumber),
                child: _buildCalendarDayCell(dayNumber, status, isSelected),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('حاضر', presentGreen),
              const SizedBox(width: 24),
              _buildLegendItem('غائب', absentRed),
              const SizedBox(width: 24),
              _buildLegendItem('معتذر', accentGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: cardSand,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textDark, size: 20),
      ),
    );
  }

  Widget _buildCalendarDayCell(
    int day,
    AttendanceStatus status,
    bool isSelected,
  ) {
    Color? dotColor;
    if (status == AttendanceStatus.present) dotColor = presentGreen;
    if (status == AttendanceStatus.absent) dotColor = absentRed;
    if (status == AttendanceStatus.excused) dotColor = accentGold;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryMaroon
            : (status != AttendanceStatus.none
                  ? cardSand.withOpacity(0.7)
                  : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              color: isSelected ? Colors.white : textDark,
              fontSize: 13,
              fontWeight: isSelected || status != AttendanceStatus.none
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
          if (dotColor != null) ...[
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected ? accentGold : dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: textDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'تفاصيل السجل',
          style: TextStyle(
            color: primaryMaroon,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cardSand,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'آخر ${_toArabicNumbers((_monthData?.records.length ?? 0).toString())} أسابيع',
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    final records = _monthData?.records ?? [];
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'لا توجد سجلات لهذا الشهر',
            style: TextStyle(color: textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildRecordCard(records[index]);
      },
    );
  }

  Widget _buildRecordCard(AttendanceRecordModel record) {
    late Color statusColor;
    late String statusLabel;
    late IconData statusIcon;
    late String subText;

    switch (record.status) {
      case AttendanceStatus.present:
        statusColor = presentGreen;
        statusLabel = 'حاضر';
        statusIcon = Icons.check_rounded;
        subText = 'تم التسجيل: ${record.checkInTime ?? ''}';
        break;
      case AttendanceStatus.absent:
        statusColor = absentRed;
        statusLabel = 'غائب';
        statusIcon = Icons.close_rounded;
        subText = record.note ?? 'لم يتم تسجيل الحضور';
        break;
      case AttendanceStatus.excused:
        statusColor = accentGold;
        statusLabel = 'معتذر';
        statusIcon = Icons.priority_high_rounded;
        subText = 'تم قبول الاعتذار مسبقاً';
        break;
      case AttendanceStatus.none:
        statusColor = textMuted;
        statusLabel = '-';
        statusIcon = Icons.remove;
        subText = '';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              record.title,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (record.status == AttendanceStatus.present) ...[
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    subText,
                                    style: const TextStyle(
                                      color: textMuted,
                                      fontSize: 11.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'الاجتماع ${record.sessionNumber}',
                            style: TextStyle(
                              color: textMuted.withOpacity(0.8),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
