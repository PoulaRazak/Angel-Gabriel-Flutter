import 'package:angel_gabriel/features/home-bottombar/screens/scanner/view.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class AppTheme {
  static const Color primary = Color(0xFF7A1428);
  static const Color primaryDark = Color(0xFF540D1B);
  static const Color accentGold = Color(0xFFD99B26);
  static const Color accentGoldLight = Color(0xFFF3B14E);
  static const Color background = Color(0xFFFAF6F3);
  static const Color cardColor = Colors.white;
  static const Color surfaceLight = Color(0xFFF3ECE7);
  static const Color textDark = Color(0xFF2B1B17);
  static const Color textMuted = Color(0xFF8C7A76);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
}

enum MeetingType { youth, bible, prayer, mass, other }

class UserProfileModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String verseOfTheDay;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.verseOfTheDay,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      verseOfTheDay: (json['verseOfTheDay'] ?? '').toString(),
    );
  }
}

class ActiveMeetingModel {
  final String id;
  final String title;
  final String statusBadge;
  final String timeRange;
  final String location;
  final bool isLive;

  const ActiveMeetingModel({
    required this.id,
    required this.title,
    required this.statusBadge,
    required this.timeRange,
    required this.location,
    required this.isLive,
  });

  factory ActiveMeetingModel.fromJson(Map<String, dynamic> json) {
    return ActiveMeetingModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      statusBadge: (json['statusBadge'] ?? 'متاح الآن').toString(),
      timeRange: (json['timeRange'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      isLive: json['isLive'] == true,
    );
  }
}

class AttendanceSummaryModel {
  final int attendedCount;
  final int totalMeetingsInMonth;
  final int streakWeeks;

  const AttendanceSummaryModel({
    required this.attendedCount,
    required this.totalMeetingsInMonth,
    required this.streakWeeks,
  });

  double get progressPercentage => totalMeetingsInMonth == 0
      ? 0.0
      : (attendedCount / totalMeetingsInMonth).clamp(0.0, 1.0);

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      attendedCount: (json['attendedCount'] as num?)?.toInt() ?? 0,
      totalMeetingsInMonth: (json['totalMeetingsInMonth'] as num?)?.toInt() ?? 0,
      streakWeeks: (json['streakWeeks'] as num?)?.toInt() ?? 0,
    );
  }
}

class LastCheckInModel {
  final String formattedDate;
  final String formattedTime;
  final bool isVerified;

  const LastCheckInModel({
    required this.formattedDate,
    required this.formattedTime,
    required this.isVerified,
  });

  factory LastCheckInModel.fromJson(Map<String, dynamic> json) {
    return LastCheckInModel(
      formattedDate: (json['formattedDate'] ?? '').toString(),
      formattedTime: (json['formattedTime'] ?? '').toString(),
      isVerified: json['isVerified'] == true,
    );
  }
}

class RecentMeetingItemModel {
  final String id;
  final String title;
  final String dateString;
  final int points;
  final bool isAttended;
  final MeetingType type;

  const RecentMeetingItemModel({
    required this.id,
    required this.title,
    required this.dateString,
    required this.points,
    required this.isAttended,
    required this.type,
  });

  static MeetingType _parseType(String raw) {
    switch (raw) {
      case 'bible':
        return MeetingType.bible;
      case 'prayer':
        return MeetingType.prayer;
      case 'mass':
        return MeetingType.mass;
      case 'other':
        return MeetingType.other;
      default:
        return MeetingType.youth;
    }
  }

  factory RecentMeetingItemModel.fromJson(Map<String, dynamic> json) {
    return RecentMeetingItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      dateString: (json['dateString'] ?? '').toString(),
      points: (json['points'] as num?)?.toInt() ?? 10,
      isAttended: json['isAttended'] == true,
      type: _parseType((json['type'] ?? 'youth').toString()),
    );
  }
}

class HomeScreenResponse {
  final UserProfileModel user;
  final ActiveMeetingModel activeMeeting;
  final AttendanceSummaryModel attendanceSummary;
  final LastCheckInModel lastCheckIn;
  final List<RecentMeetingItemModel> recentMeetings;

  const HomeScreenResponse({
    required this.user,
    required this.activeMeeting,
    required this.attendanceSummary,
    required this.lastCheckIn,
    required this.recentMeetings,
  });

  factory HomeScreenResponse.fromJson(Map<String, dynamic> json) {
    final recentList = json['recentMeetings'] as List<dynamic>? ?? [];
    return HomeScreenResponse(
      user: UserProfileModel.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      activeMeeting: ActiveMeetingModel.fromJson(
        (json['activeMeeting'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      attendanceSummary: AttendanceSummaryModel.fromJson(
        (json['attendanceSummary'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      lastCheckIn: LastCheckInModel.fromJson(
        (json['lastCheckIn'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      recentMeetings: recentList
          .map((e) => RecentMeetingItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HomeApiService {
  Future<HomeScreenResponse> fetchHomeScreenData() async {
    final json = await ApiClient.get('/home');
    return HomeScreenResponse.fromJson(json);
  }

  Future<bool> setMeetingReminder() async {
    final json = await ApiClient.post('/home/reminder');
    return json['success'] == true;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApiService _apiService = HomeApiService();
  late Future<HomeScreenResponse> _homeDataFuture;
  bool _isReminderLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _homeDataFuture = _apiService.fetchHomeScreenData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
    await _homeDataFuture;
  }

  void _onSetReminder() async {
    setState(() => _isReminderLoading = true);
    try {
      final success = await _apiService.setMeetingReminder();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تفعيل تذكير موعد الاجتماع القادم بنجاح'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isReminderLoading = false);
    }
  }

  Future<void> _openScannerAndRefresh() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRPage()),
    );
    if (mounted) {
      await _refreshData();
    }
  }

  void _onViewFullHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يمكنك تصفح السجل الكامل من تبويب الحضور بالأسفل')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FutureBuilder<HomeScreenResponse>(
          future: _homeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorView(onRetry: _refreshData);
            }

            final data = snapshot.data!;

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _refreshData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _CustomTopAppBar(),
                        const SizedBox(height: 24),
                        _WelcomeSection(user: data.user),
                        const SizedBox(height: 20),
                        _ActiveMeetingHeroCard(meeting: data.activeMeeting),
                        const SizedBox(height: 16),
                        _CheckInCard(
                          lastCheckIn: data.lastCheckIn,
                          onScanTap: _openScannerAndRefresh,
                        ),
                        const SizedBox(height: 16),
                        _AttendanceProgressCard(
                          summary: data.attendanceSummary,
                        ),
                        const SizedBox(height: 16),
                        _ReminderBannerCard(
                          isLoading: _isReminderLoading,
                          onRemindTap: _onSetReminder,
                        ),
                        const SizedBox(height: 28),
                        _RecentAttendanceHeader(onViewAll: _onViewFullHistory),
                        const SizedBox(height: 12),
                        if (data.recentMeetings.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text(
                              'لا توجد جلسات حضور مسجلة حتى الآن',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          ...data.recentMeetings.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RecentMeetingCard(item: item),
                            ),
                          ),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CustomTopAppBar extends StatelessWidget {
  const _CustomTopAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'أُسْرَةُ المَلَاكِ غَبْرِيَالَ',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Icon(
          Icons.verified_rounded,
          color: AppTheme.accentGold,
          size: 24,
        ),
      ],
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final UserProfileModel user;

  const _WelcomeSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أهلاً بك، ${user.fullName}',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.verseOfTheDay,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActiveMeetingHeroCard extends StatelessWidget {
  final ActiveMeetingModel meeting;

  const _ActiveMeetingHeroCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -15,
            bottom: -15,
            child: Icon(
              Icons.church_outlined,
              size: 110,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meeting.statusBadge,
                  style: const TextStyle(
                    color: AppTheme.accentGoldLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                meeting.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: AppTheme.accentGoldLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meeting.timeRange,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.accentGoldLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meeting.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final LastCheckInModel lastCheckIn;
  final VoidCallback onScanTap;

  const _CheckInCard({
    required this.lastCheckIn,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'تسجيل الحضور',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'قم بمسح الكود الخاص بك عند مدخل القاعة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onScanTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGoldLight,
                foregroundColor: AppTheme.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'امسح كود الحضور (QR)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppTheme.surfaceLight),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر تسجيل حضور:',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.success,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      lastCheckIn.isVerified
                          ? '${lastCheckIn.formattedDate} (${lastCheckIn.formattedTime})'
                          : lastCheckIn.formattedDate,
                      style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceProgressCard extends StatelessWidget {
  final AttendanceSummaryModel summary;

  const _AttendanceProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'نسبة الحضور هذا الشهر',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${summary.attendedCount} من ${summary.totalMeetingsInMonth} اجتماعات',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: summary.progressPercentage,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: AppTheme.accentGold,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'مواظب على الحضور منذ ${summary.streakWeeks} أسابيع متتالية! استمر في النمو الروحي',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderBannerCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRemindTap;

  const _ReminderBannerCard({
    required this.isLoading,
    required this.onRemindTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تذكير الاجتماع القادم',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'فعل التنبيهات لتصلك رسالة قبل الموعد بساعتين',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isLoading ? null : onRemindTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ذكرني',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecentAttendanceHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const _RecentAttendanceHeader({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'سجل الحضور الأخير',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          child: const Text(
            'عرض السجل الكامل',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _RecentMeetingCard extends StatelessWidget {
  final RecentMeetingItemModel item;

  const _RecentMeetingCard({required this.item});

  IconData _getIconForType(MeetingType type) {
    switch (type) {
      case MeetingType.youth:
        return Icons.groups_rounded;
      case MeetingType.bible:
        return Icons.menu_book_rounded;
      case MeetingType.prayer:
        return Icons.volunteer_activism_rounded;
      case MeetingType.mass:
        return Icons.church_rounded;
      case MeetingType.other:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIconForType(item.type),
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.dateString,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.isAttended ? 'تم الحضور' : 'غائب',
                style: TextStyle(
                  color: item.isAttended ? AppTheme.success : Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '+${item.points} نقطة',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ أثناء تحميل البيانات',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
