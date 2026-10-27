import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Your external colors file (class AppColors).
import '../../../../core/resources/app-colors.dart';

/* ========================================================================== */
/*  MODELS                                                                    */
/* ========================================================================== */

class AttendanceResult {
  final String serviceName; // الخدمة / الاجتماع
  final String dateLabel; // التاريخ
  final String timeLabel; // وقت التسجيل
  final int points; // نقاط الحضور

  const AttendanceResult({
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.points,
  });
}

/// Throw this from the API service to show a custom error message.
class AttendanceException implements Exception {
  final String message;
  const AttendanceException(this.message);
}

/* ========================================================================== */
/*  API SERVICE  (empty on purpose: put your API logic here)                  */
/* ========================================================================== */

class AttendanceApiService {
  /// Send the scanned QR value to your server and return the result.
  Future<AttendanceResult> registerAttendance(String qrCode) async {
    // TODO: call your API here and parse the response, for example:
    //
    // final response = await dio.post('/attendance/scan', data: {'code': qrCode});
    // return AttendanceResult(
    //   serviceName: response.data['service'],
    //   dateLabel: response.data['date'],
    //   timeLabel: response.data['time'],
    //   points: response.data['points'],
    // );
    //
    // If the code is invalid / expired:
    // throw const AttendanceException('رمز غير صالح أو منتهي الصلاحية');

    // Temporary placeholder so the screen works. Remove when API is ready.
    await Future.delayed(const Duration(milliseconds: 800));
    return const AttendanceResult(
      serviceName: 'اجتماع الشباب العام',
      dateLabel: 'الجمعة 27 أكتوبر 2023',
      timeLabel: '07:10 مساءً',
      points: 10,
    );
  }

  /// Ask the hall servant for help.
  Future<void> requestHelp() async {
    // TODO: call your help-request API here.
  }
}

/* ========================================================================== */
/*  EXTRA COLORS (not in your AppColors) + TEXT HELPER                        */
/* ========================================================================== */

class _QC {
  static const successDark = Color(0xFF0B4D2C);
  static const titleGreen = Color(0xFF0B3D24);
  static const success = Color(0xFF2E9E5B);
  static const successLight = Color(0xFF6FD99A);
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

enum _ScanStatus { scanning, processing, success, failure }

/* ========================================================================== */
/*  QR PAGE                                                                   */
/*  Open it with:                                                             */
/*  Navigator.push(context, MaterialPageRoute(builder: (_) => const QRPage()))*/
/* ========================================================================== */

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> with WidgetsBindingObserver {
  final _service = AttendanceApiService();

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  _ScanStatus _status = _ScanStatus.scanning;
  AttendanceResult? _result;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // Stop the camera when the app goes to background, restart when it returns.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (_status == _ScanStatus.scanning) _safeStart();
        break;
      case AppLifecycleState.inactive:
        _safeStop();
        break;
      default:
        break;
    }
  }

  Future<void> _safeStart() async {
    try {
      await _controller.start();
    } catch (_) {}
  }

  Future<void> _safeStop() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  // ---------------------------------------------------------------- Logic
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_status != _ScanStatus.scanning) return;

    String? code;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        code = v;
        break;
      }
    }
    if (code == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _status = _ScanStatus.processing);

    try {
      final result = await _service.registerAttendance(code);
      if (!mounted) return;
      setState(() {
        _result = result;
        _status = _ScanStatus.success;
      });
      _safeStop();
    } on AttendanceException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _status = _ScanStatus.failure;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تسجيل الحضور، حاول مرة أخرى';
        _status = _ScanStatus.failure;
      });
    }
  }

  void _scanAgain() {
    setState(() {
      _result = null;
      _errorMessage = '';
      _status = _ScanStatus.scanning;
    });
    _safeStart();
  }

  void _onShare() {
    // TODO: share the attendance result (e.g. with the share_plus package).
  }

  Future<void> _onRequestHelp() async {
    // TODO: call _service.requestHelp() and show feedback to the user.
    await _service.requestHelp();
  }

  void _goHome() {
    // Pass `true` if you want the home screen to refresh after a success.
    Navigator.maybePop(context, _status == _ScanStatus.success);
  }

  // ---------------------------------------------------------------- Build
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              fit: BoxFit.cover,
            ),
            // Dark overlay
            Container(color: Colors.black.withOpacity(0.35)),
            // Top gradient for header readability
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildCameraArea()),
                  _buildSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // Back pill (right side in RTL). arrow_back is mirrored in RTL.
          InkWell(
            onTap: _goHome,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text('الرجوع للرئيسية',
                      style: _t(11,
                          weight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('مسح رمز الحضور',
                    style: _t(16, weight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, _) {
                    final active = state.isRunning;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          active ? 'الكاميرا متصلة ونشطة' : 'الكاميرا متوقفة',
                          style: _t(10, color: Colors.white70),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? _QC.success : AppColors.hint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Flash button (left side in RTL)
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final on = state.torchState == TorchState.on;
              final unavailable = state.torchState == TorchState.unavailable;
              return Opacity(
                opacity: unavailable ? 0.4 : 1,
                child: InkWell(
                  onTap: unavailable ? null : () => _controller.toggleTorch(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: on
                          ? AppColors.gold
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Icon(
                      on ? Icons.flash_on : Icons.flash_off,
                      color: on ? AppColors.burgundy : AppColors.gold,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- Camera area
  Widget _buildCameraArea() {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: _controller,
      builder: (context, state, _) {
        // Camera error (e.g. permission denied)
        if (state.error != null) {
          final denied =
              state.error!.errorCode == MobileScannerErrorCode.permissionDenied;
          return _cameraError(denied);
        }

        return LayoutBuilder(
          builder: (context, c) {
            final side = math
                .min(c.maxWidth * 0.7, c.maxHeight * 0.85)
                .clamp(110.0, 260.0)
                .toDouble();
            return Center(
              child: SizedBox(
                width: side,
                height: side,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(side, side),
                      painter: _CornerPainter(color: AppColors.gold),
                    ),
                    Icon(
                      Icons.center_focus_weak,
                      color: Colors.white.withOpacity(0.8),
                      size: 30,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _cameraError(bool denied) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined,
                color: Colors.white70, size: 40),
            const SizedBox(height: 10),
            Text(
              denied ? 'لا يمكن الوصول إلى الكاميرا' : 'تعذر تشغيل الكاميرا',
              style: _t(14, weight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              denied
                  ? 'اسمح بالوصول إلى الكاميرا من إعدادات الهاتف ثم حاول مرة أخرى'
                  : 'حاول مرة أخرى أو أعد تشغيل التطبيق',
              textAlign: TextAlign.center,
              style: _t(11, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _safeStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('إعادة المحاولة',
                  style: _t(12, weight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- Bottom sheet
  Widget _buildSheet() {
    final maxH = MediaQuery.of(context).size.height * 0.78;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: Color.lerp(AppColors.fieldFill, Colors.white, 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_status),
                    child: _sheetContent(),
                  ),
                ),
                const SizedBox(height: 14),
                _buildHelpRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetContent() {
    switch (_status) {
      case _ScanStatus.scanning:
        return _scanningContent();
      case _ScanStatus.processing:
        return _processingContent();
      case _ScanStatus.success:
        return _successContent(_result!);
      case _ScanStatus.failure:
        return _failureContent();
    }
  }

  // ----------------------------------------------------------- Scanning
  Widget _scanningContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.fieldFill,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Icon(Icons.qr_code_scanner,
                color: AppColors.burgundy, size: 28),
          ),
          const SizedBox(height: 12),
          Text('وجّه الكاميرا نحو رمز QR',
              style: _t(17, weight: FontWeight.w800, color: AppColors.burgundy)),
          const SizedBox(height: 4),
          Text(
            'ضع الرمز داخل الإطار وسيتم تسجيل حضورك تلقائياً',
            textAlign: TextAlign.center,
            style: _t(11.5, color: AppColors.textGrey, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- Processing
  Widget _processingContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.burgundy,
              strokeWidth: 3.5,
            ),
          ),
          const SizedBox(height: 14),
          Text('جارٍ تسجيل حضورك...',
              style: _t(14, weight: FontWeight.w800, color: AppColors.burgundy)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ Success
  Widget _successContent(AttendanceResult r) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _QC.successBg),
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFEAF8EF), Colors.white, Colors.white],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Check badge
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _QC.success.withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: _QC.success.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: _QC.successDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: _QC.successLight, size: 30),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('تم تسجيل حضورك بنجاح!',
                  style:
                  _t(21, weight: FontWeight.w800, color: _QC.titleGreen)),
              const SizedBox(height: 6),
              Text(
                'أهلاً بك، بركة صلواتك معنا اليوم تثري جسد الكنيسة والخدمة.',
                textAlign: TextAlign.center,
                style: _t(12, color: AppColors.textGrey, height: 1.6),
              ),
              const SizedBox(height: 16),
              // Details box
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Column(
                  children: [
                    _detailRow(
                      icon: Icons.event_available_outlined,
                      label: 'الخدمة / الاجتماع',
                      value: Text(r.serviceName,
                          style: _t(12,
                              weight: FontWeight.w800,
                              color: AppColors.burgundy)),
                    ),
                    const SizedBox(height: 14),
                    _detailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'التاريخ',
                      value: Text(r.dateLabel,
                          style: _t(12, weight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 14),
                    _detailRow(
                      icon: Icons.access_time,
                      label: 'وقت التسجيل',
                      value: Text(r.timeLabel,
                          style: _t(12, weight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 14),
                    _detailRow(
                      icon: Icons.star_border_rounded,
                      iconColor: AppColors.gold,
                      label: 'نقاط الحضور',
                      value: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _QC.successBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _QC.success.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                size: 13, color: _QC.success),
                            const SizedBox(width: 2),
                            Text('${r.points} نقاط',
                                style: _t(11,
                                    weight: FontWeight.w800,
                                    color: _QC.success)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Actions
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onShare,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.burgundy,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: AppColors.burgundy.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share, size: 18),
                            const SizedBox(width: 6),
                            Text('مشاركة',
                                style: _t(14,
                                    weight: FontWeight.w800,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _scanAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.fieldBorder,
                          foregroundColor: AppColors.textGrey,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text('مسح جديد',
                            style: _t(11,
                                weight: FontWeight.w800,
                                color: AppColors.textGrey)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required Widget value,
    Color iconColor = AppColors.burgundy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(label, style: _t(11.5, color: AppColors.textGrey)),
        const Spacer(),
        value,
      ],
    );
  }

  // ------------------------------------------------------------ Failure
  Widget _failureContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _QC.dangerBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline,
                color: _QC.danger, size: 30),
          ),
          const SizedBox(height: 12),
          Text('لم يتم تسجيل الحضور',
              style: _t(17, weight: FontWeight.w800, color: _QC.danger)),
          const SizedBox(height: 4),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: _t(11.5, color: AppColors.textGrey, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _scanAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('إعادة المحاولة',
                  style: _t(13, weight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- Help
  Widget _buildHelpRow() {
    return Column(
      children: [
        Text('تواجه صعوبة في مسح الرمز؟',
            style: _t(11, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _onRequestHelp,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.support_agent,
                    size: 18, color: AppColors.burgundy),
                const SizedBox(width: 6),
                Text('طلب المساعدة من خادم النظام بالقاعة',
                    style: _t(11.5,
                        weight: FontWeight.w800, color: AppColors.burgundy)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: AppColors.fieldBorder.withOpacity(0.7)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

/* ========================================================================== */
/*  Scanner frame corners                                                     */
/* ========================================================================== */

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    const r = 16.0;
    final w = size.width;
    final h = size.height;

    final path = Path()
    // top-left
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..arcTo(const Rect.fromLTWH(0, 0, r * 2, r * 2), math.pi, math.pi / 2,
          false)
      ..lineTo(len, 0)
    // top-right
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..arcTo(Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2), -math.pi / 2,
          math.pi / 2, false)
      ..lineTo(w, len)
    // bottom-right
      ..moveTo(w, h - len)
      ..lineTo(w, h - r)
      ..arcTo(Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2), 0,
          math.pi / 2, false)
      ..lineTo(w - len, h)
    // bottom-left
      ..moveTo(len, h)
      ..lineTo(r, h)
      ..arcTo(Rect.fromLTWH(0, h - r * 2, r * 2, r * 2), math.pi / 2,
          math.pi / 2, false)
      ..lineTo(0, h - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}