import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/resources/app-colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("لا يوجد اشعارات",
      style: GoogleFonts.tajawal(
        fontSize: 14,
        color: AppColors.burgundy,
        fontWeight: FontWeight.w500,
      ),
      ),
    );
  }
}
