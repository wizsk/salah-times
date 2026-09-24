import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/models/prayer_time.dart';
import 'package:salah_times/theme/app_theme.dart';
import 'package:salah_times/utils/number.dart';
import 'package:salah_times/widgets/star_badge.dart';

class PrayerHeroCard extends StatelessWidget {
  PrayerHeroCard({super.key, required this.info, required this.now})
    : assert(info.next != null, 'this can not be null');

  final NextPrayerInfo info;
  final DateTime now;

  static String _countdownLabel(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;

    if (m == 0 && h == 0) {
      return switch (L.curr) {
        L.en => 'under 1m',
        L.bn => '১মি এর মধ্যে',
      };
    }

    if (h > 0 && m == 0) {
      return switch (L.curr) {
        L.en => 'in ${h}h',
        L.bn => '${h.bn}ঘ পর',
      };
    }

    if (h > 0) {
      return switch (L.curr) {
        L.en => 'in ${h}h ${m}m',
        L.bn => '${h.bn}ঘ ${m.bn}মি পর',
      };
    }

    return switch (L.curr) {
      L.en => 'in ${m}m',
      L.bn => '${m.bn}মি পর',
    };
  }

  static String _prohibitedMinFMT(int m) {
    if (m == 0) {
      return switch (L.curr) {
        L.en => 'for less than 1m',
        L.bn => '১মি এর কম',
      };
    }

    return switch (L.curr) {
      L.en => 'for ${m}m',
      L.bn => '${m.bn}মি এর জন্যে',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final next = info.next!;

    bool noPrayerWarn = false;
    int noPrayerForMin = 0;
    double noPrayerTotal = 1;

    if (next.p == PrayerEntry.dhuhr) {
      final rem = info.remaining!.inMinutes;
      if (rem <= 5) {
        noPrayerWarn = true;
        noPrayerForMin = rem;
        noPrayerTotal = 5;
      }
    }

    if (next.p == PrayerEntry.maghrib) {
      final rem = info.remaining!.inMinutes;
      if (rem <= 15) {
        noPrayerWarn = true;
        noPrayerForMin = rem;
        noPrayerTotal = 15;
      }
    }

    if (info.curr?.p == PrayerEntry.sunrise) {
      final m = info.curr!.toMin;
      final rem = 15 - (((now.hour * 60) + now.minute) - m);

      noPrayerWarn = true;
      noPrayerForMin = rem;
      noPrayerTotal = 15;
    }

    final nextPrayerMainLabel = next.p == PrayerEntry.sunrise
        ? PrayerEntry.fajrEnds
        : noPrayerWarn
        ? PrayerEntry.salahProhibitaedLabel
        : next.name;

    final progress = noPrayerWarn
        ? (noPrayerTotal - noPrayerForMin.toDouble()) / noPrayerTotal
        : info.progress;

    final progressFrom = noPrayerWarn && info.curr?.p != PrayerEntry.sunrise
        ? PrayerEntry.salahProhibitaedLabel
        : info.curr?.name;

    final progressTo = info.curr?.p == PrayerEntry.sunrise ? null : next.name;

    final countDownLabel = noPrayerWarn
        ? _prohibitedMinFMT(noPrayerForMin)
        : _countdownLabel(info.remaining!);

    final use24h = MediaQuery.of(context).alwaysUse24HourFormat;
    final (hm, amapm) = noPrayerWarn && info.curr?.p == PrayerEntry.sunrise
        ? PrayerTimingEntry(
            PrayerEntry.sunrise,
            now.copyWith(minute: now.minute + noPrayerForMin),
          ).fmtHMAMPM(use24h)
        : next.fmtHMAMPM(use24h);

    final fg = noPrayerWarn
        ? scheme.onErrorContainer
        : scheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.85],
          colors: noPrayerWarn
              ? [scheme.errorContainer, scheme.errorContainer.withAlpha(100)]
              : [scheme.primaryContainer, scheme.surfaceContainerHigh],
          // colors: [scheme.primaryContainer, scheme.surfaceContainerHigh],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: fg.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                switch (L.curr) {
                  L.en => 'NEXT PRAYER',
                  L.bn => 'পরবর্তি নামাজ',
                },
                style: textTheme.labelSmall?.copyWith(
                  color: fg.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  // letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StarBadge(
                icon: noPrayerWarn ? Icons.block : next.icon,
                fg: noPrayerWarn ? scheme.onError : scheme.onPrimary,
                bg: noPrayerWarn ? scheme.error : scheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      nextPrayerMainLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: AppTheme.displayFont,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    if (info.remaining != null)
                      Text(
                        countDownLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          color: fg.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  text: hm,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: AppTheme.displayFont,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                  children: amapm.isEmpty
                      ? null
                      : [
                          TextSpan(
                            text: '  $amapm',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: fg.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: fg.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation(
                noPrayerWarn ? scheme.error : scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(progressFrom ?? '...', style: _labelStyle(textTheme, fg)),
              Text(progressTo ?? '...', style: _labelStyle(textTheme, fg)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle? _labelStyle(TextTheme textTheme, Color c) {
    return textTheme.labelMedium?.copyWith(
      color: c.withValues(alpha: 0.65),
      fontWeight: FontWeight.w600,
    );
  }
}
