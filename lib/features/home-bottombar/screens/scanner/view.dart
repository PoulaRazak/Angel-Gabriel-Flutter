import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/network/api_client.dart';

class AttendanceScanResult {
  final bool success;
  final String message;
  final String? studentName;
  final String? meetingTitle;
  final DateTime? timestamp;

  const AttendanceScanResult({
    required this.success,
    required this.message,
    this.studentName,
    this.meetingTitle,
    this.timestamp,
  });

  factory AttendanceScanResult.fromJson(Map<String, dynamic> json) {
    return AttendanceScanResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      studentName: json['studentName']?.toString(),
      meetingTitle: json['meetingTitle']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : DateTime.now(),
    );
  }
}

class AttendanceApiService {
  Future<AttendanceScanResult> submitQrAttendance({
    required String qrCode,
  }) async {
    try {
      final json = await ApiClient.post(
        '/attendance/scan',
        body: {'qrCode': qrCode},
      );
      return AttendanceScanResult.fromJson(json);
    } catch (e) {
      return AttendanceScanResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<void> requestSystemServantHelp() async {
    await ApiClient.post(
      '/attendance/help',
      body: {
        'message': 'طلب مساعدة لتسجيل الحضور من شاشة مسح QR بالقاعة',
      },
    );
  }
}

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> with SingleTickerProviderStateMixin {
  static const Color kPrimaryBurgundy = Color(0xFF7B1E2B);
  static const Color kAccentGold = Color(0xFFD4AF37);
  static const Color kCreamBackground = Color(0xFFFAF6F2);
  static const Color kCardSand = Color(0xFFF3ECE4);
  static const Color kScannerDark = Color(0xFF231917);
  static const Color kTextDark = Color(0xFF2D1E1B);
  static const Color kTextMuted = Color(0xFF7A6A65);

  final AttendanceApiService _apiService = AttendanceApiService();
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;

  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    await _scannerController.stop();

    try {
      final result = await _apiService.submitQrAttendance(qrCode: rawValue);
      if (!mounted) return;
      await _showResultBottomSheet(result);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('حدث خطأ أثناء الاتصال بالخادم، حاول مرة أخرى.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        await _scannerController.start();
      }
    }
  }

  Future<void> _toggleFlash() async {
    await _scannerController.toggleTorch();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  Future<void> _switchCamera() async {
    await _scannerController.switchCamera();
  }

  Future<void> _onHelpRequested() async {
    try {
      await _apiService.requestSystemServantHelp();
      if (!mounted) return;
      _showSnackBar('تم إرسال طلب المساعدة لخادم النظام بالقاعة.');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('تعذر إرسال الطلب حالياً.', isError: true);
    }
  }

  void _showSnackBar(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red.shade700 : kPrimaryBurgundy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showResultBottomSheet(AttendanceScanResult result) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCreamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: result.success
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Icon(
                    result.success
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    size: 48,
                    color: result.success
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                if (result.meetingTitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    result.meetingTitle!,
                    style: const TextStyle(fontSize: 14, color: kTextMuted),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBurgundy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (result.success && mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text(
                      result.success ? 'العودة للرئيسية' : 'مسح مرة أخرى',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kCreamBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'مسح رمز الاستجابة السريع',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryBurgundy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'وجه الكاميرا نحو الرمز الموجود في القاعة لتسجيل حضورك فوراً في الاجتماع',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: kTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _buildScannerCard(),
                const SizedBox(height: 20),
                _buildCameraControlsRow(),
                const SizedBox(height: 20),
                _buildInstructionCard(),
                const SizedBox(height: 18),
                _buildHelpButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCreamBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: kPrimaryBurgundy,
          size: 26,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kPrimaryBurgundy.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: kAccentGold, width: 1.2),
            ),
            child: const Icon(
              Icons.church_rounded,
              color: kPrimaryBurgundy,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'أُسْرَةُ المَلَاكِ غَبْرِيَالَ',
            style: TextStyle(
              color: kPrimaryBurgundy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCard() {
    return AspectRatio(
      aspectRatio: 0.88,
      child: Container(
        decoration: BoxDecoration(
          color: kScannerDark,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
              errorBuilder: (context, error) {
                return _buildScannerPlaceholder();
              },
            ),
            Container(color: Colors.black.withOpacity(0.35)),
            LayoutBuilder(
              builder: (context, constraints) {
                final double frameSize = constraints.maxWidth * 0.68;
                return SizedBox(
                  width: frameSize,
                  height: frameSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 96,
                        color: Colors.white24,
                      ),
                      CustomPaint(
                        size: Size(frameSize, frameSize),
                        painter: _GoldCornersPainter(
                          color: kAccentGold,
                          strokeWidth: 4.0,
                          cornerLength: 28.0,
                          radius: 18.0,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _laserController,
                        builder: (context, child) {
                          final double dy =
                              (_laserController.value * (frameSize - 40)) + 20;
                          return Positioned(
                            top: dy,
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: kAccentGold,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: kAccentGold.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 1.5,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: kAccentGold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerPlaceholder() {
    return Container(
      color: kScannerDark,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 42),
          SizedBox(height: 8),
          Text(
            'الكاميرا قيد التشغيل...',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControlsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildControlPillButton(
            label: _isFlashOn ? 'إيقاف الفلاش' : 'تشغيل الفلاش',
            icon: _isFlashOn
                ? Icons.flashlight_off_rounded
                : Icons.flashlight_on_rounded,
            isActive: _isFlashOn,
            onTap: _toggleFlash,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildControlPillButton(
            label: 'تبديل الكاميرا',
            icon: Icons.cameraswitch_rounded,
            isActive: false,
            onTap: _switchCamera,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPillButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? kPrimaryBurgundy : kCardSand,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 20,
                color: isActive ? kAccentGold : kPrimaryBurgundy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardSand.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.brown.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: kPrimaryBurgundy,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعليمات التسجيل',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'يرجى التأكد من استقرار اليد أثناء المسح وتوافر إضاءة كافية. في حال تعذر المسح، يمكنك مراجعة خادم النظام لتسجيلك يدوياً.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: kTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton() {
    return TextButton.icon(
      onPressed: _onHelpRequested,
      style: TextButton.styleFrom(
        foregroundColor: kPrimaryBurgundy,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: const Icon(Icons.help_rounded, size: 20, color: kPrimaryBurgundy),
      label: const Text(
        'طلب المساعدة من خادم النظام بالقاعة',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: kPrimaryBurgundy,
        ),
      ),
    );
  }
}

class _GoldCornersPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  _GoldCornersPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;
    final double r = radius;
    final double len = cornerLength;

    final Path path = Path()
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(len, 0)
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, len)
      ..moveTo(0, h - len)
      ..lineTo(0, h - r)
      ..arcToPoint(Offset(r, h), radius: Radius.circular(r), clockwise: false)
      ..lineTo(len, h)
      ..moveTo(w - len, h)
      ..lineTo(w - r, h)
      ..arcToPoint(Offset(w, h - r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(w, h - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldCornersPainter oldDelegate) => false;
}
