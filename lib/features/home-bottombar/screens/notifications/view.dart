import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class NotificationItemModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String dateLabel;
  final String timeLabel;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.dateLabel,
    required this.timeLabel,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? 'general').toString(),
      isRead: json['isRead'] == true,
      dateLabel: (json['dateLabel'] ?? '').toString(),
      timeLabel: (json['timeLabel'] ?? '').toString(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color primaryCrimson = Color(0xFF7A182B);
  static const Color accentGold = Color(0xFFFCC260);
  static const Color bgCream = Color(0xFFFFF8F6);
  static const Color textDark = Color(0xFF2B1B17);
  static const Color textMuted = Color(0xFF8C7A76);

  bool _isLoading = true;
  List<NotificationItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/notifications');
      final rawList = response['notifications'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _items = rawList
            .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationItemModel item) async {
    if (item.isRead) return;
    try {
      await ApiClient.post(
        '/notifications/read',
        body: {'notificationId': item.id},
      );
      await _loadNotifications();
    } catch (_) {}
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'attendance':
        return Icons.qr_code_scanner_rounded;
      case 'event':
        return Icons.celebration_rounded;
      case 'approval':
        return Icons.verified_user_rounded;
      case 'reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCream,
        appBar: AppBar(
          backgroundColor: bgCream,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الإشعارات والتنبيهات',
            style: TextStyle(
              color: primaryCrimson,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded, color: primaryCrimson),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryCrimson),
              )
            : _items.isEmpty
                ? const Center(
                    child: Text(
                      'لا يوجد إشعارات حالياً',
                      style: TextStyle(
                        color: primaryCrimson,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: primaryCrimson,
                    onRefresh: _loadNotifications,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return InkWell(
                          onTap: () => _markAsRead(item),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: item.isRead
                                    ? Colors.black.withOpacity(0.05)
                                    : accentGold,
                                width: item.isRead ? 1 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: primaryCrimson.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _iconForType(item.type),
                                    color: primaryCrimson,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: const TextStyle(
                                                color: textDark,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (!item.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: primaryCrimson,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.body,
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${item.dateLabel} • ${item.timeLabel}',
                                        style: TextStyle(
                                          color: textMuted.withOpacity(0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
