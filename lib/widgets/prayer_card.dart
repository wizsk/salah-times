import 'package:flutter/material.dart';

class PrayerCard extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;
  final bool isNext;
  final bool isCurrent;
  final bool isPrayer; // false for Sunrise — never highlighted as current/next
  final Color accentColor;

  const PrayerCard({
    super.key,
    required this.name,
    required this.time,
    required this.icon,
    required this.accentColor,
    this.isNext = false,
    this.isCurrent = false,
    this.isPrayer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg;
    final Color textColor;
    final Color subColor;

    if (isCurrent) {
      cardBg = accentColor;
      textColor = Colors.white;
      subColor = Colors.white.withAlpha(179);
    } else if (isNext) {
      cardBg = isDark
          ? accentColor.withAlpha(51)
          : accentColor.withAlpha(31);
      textColor = isDark ? Colors.white : Colors.black87;
      subColor = isDark ? Colors.white60 : Colors.black54;
    } else {
      cardBg = isDark ? const Color(0xFF1E2D45) : Colors.white;
      textColor = isDark ? Colors.white : Colors.black87;
      subColor = isDark ? Colors.white.withAlpha(138) : Colors.black.withAlpha(115);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isNext && !isCurrent
            ? Border.all(color: accentColor.withAlpha(128), width: 1.5)
            : null,
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: accentColor.withAlpha(102),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 51 : 15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrent
                    ? Colors.white.withAlpha(51)
                    : accentColor.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isCurrent ? Colors.white : accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (!isPrayer)
                    Text(
                      'Not a prayer',
                      style: TextStyle(fontSize: 11, color: subColor),
                    )
                  else if (isCurrent)
                    Text(
                      'Current prayer',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withAlpha(204),
                          fontWeight: FontWeight.w500),
                    )
                  else if (isNext)
                    Text(
                      'Next prayer',
                      style: TextStyle(
                          fontSize: 11,
                          color: accentColor,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
            Text(
              _fmt(time),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isCurrent ? Colors.white : textColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String t) {
    if (t.isEmpty) return '--:--';
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m = p[1];
      final ampm = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $ampm';
    } catch (_) {
      return t;
    }
  }
}
