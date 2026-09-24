import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_day.dart';

import '../theme/app_theme.dart';

/// A grouped M3 list card: Fajr → Isha with Sunrise as a non-prayer marker
/// row, dividers between rows, and the current "next" prayer highlighted.
class PrayerListCard extends StatelessWidget {
  const PrayerListCard({
    super.key,
    required this.prayer,
    required this.next,
    required this.curr,
  });

  final PrayerDay prayer;
  final PrayerEntry? next;
  final PrayerEntry? curr;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final en = prayer.timings.en;
    final ln = en.length - 2;
    final use24h = MediaQuery.of(context).alwaysUse24HourFormat;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            for (var i = 0; i < ln; i++) ...[
              _PrayerRow(en: en[i], next: next, curr: curr, use24h: use24h),
              if (i != ln - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 18,
                  endIndent: 18,
                  color: scheme.outlineVariant.withValues(
                    alpha:
                        (en[i].p == curr || (i + 1 < ln && en[i + 1].p == curr))
                        ? 0
                        : 1,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.en,
    required this.next,
    required this.curr,
    required this.use24h,
  });

  final PrayerTimingEntry en;
  final PrayerEntry? next;
  final PrayerEntry? curr;
  final bool use24h;

  @override
  Widget build(BuildContext context) {
    final bool isNext = en.p == next;
    final bool isCurr = en.p == curr;

    final (hm, amapm) = en.fmtHMAMPM(use24h);

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // final timeParts = prayer.time12.split(' ');

    final fg = isCurr ? scheme.onPrimaryContainer : scheme.onSurface;
    final fgMuted = isCurr
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: isCurr ? scheme.primaryContainer : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurr ? scheme.primary : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              en.icon,
              size: 21,
              color: isCurr ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  en.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                if (en.isNorPrayer)
                  Text(
                    switch (L.curr) {
                      L.en => 'Not a prayer',
                      L.bn => 'নামাজের সময় না',
                    },
                    style: textTheme.labelSmall?.copyWith(
                      color: fgMuted.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
          if (isNext) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'NEXT',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text.rich(
            TextSpan(
              text: hm,
              style: textTheme.titleMedium?.copyWith(
                fontFamily: AppTheme.displayFont,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
              children: amapm.isEmpty
                  ? null
                  : [
                      TextSpan(
                        text: ' $amapm',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: fgMuted.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
