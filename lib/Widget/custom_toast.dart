import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greennest/Util/colors.dart';
import 'package:overlay_support/overlay_support.dart';

class CustomToast {
  static void show({
    required String title,
    required String message,
    required Color bgColor,
    required String iconUrl,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSimpleNotification(
      Row(
        children: [
          Image.network(
            iconUrl,
            height: 26,
            width: 26,
            color: white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold, color: white)),
                const SizedBox(height: 2),
                Text(message, style: GoogleFonts.urbanist(color: white)),
              ],
            ),
          ),
        ],
      ),
      background: bgColor,
      duration: duration,
      elevation: 4,
    );
  }
}
