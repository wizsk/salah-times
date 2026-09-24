import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/theme/app_theme.dart';
import 'package:salah_times/utils/number.dart';
import 'package:salah_times/widgets/star_badge.dart';

import '../models/prayer_time.dart';

class PrayerHeroCard extends StatelessWidget {
  PrayerHeroCard({super.key, required this.info})
    : assert(info.next != null, 'this can not be null');

  final NextPrayerInfo info;

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final next = info.next!;
    final nextLabel = next.p == PrayerEntry.sunrise
        ? PrayerEntry.fajrEnds
        : next.name;

    final use24h = MediaQuery.of(context).alwaysUse24HourFormat;
    final (hm, amapm) = next.fmtHMAMPM(use24h);

    if (next.p == PrayerEntry.dhuhr) {
      // do stuff...
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.85],
          colors: [scheme.primaryContainer, scheme.surfaceContainerHigh],
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
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'NEXT PRAYER',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StarBadge(icon: next.icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      nextLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: AppTheme.displayFont,
                        fontWeight: FontWeight.w600,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    if (info.remaining != null)
                      Text(
                        _countdownLabel(info.remaining!),
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer.withValues(
                            alpha: 0.85,
                          ),
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
                    color: scheme.onPrimaryContainer,
                  ),
                  children: amapm.isEmpty
                      ? null
                      : [
                          TextSpan(
                            text: '  $amapm',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              ),
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
              value: info.progress,
              minHeight: 6,
              backgroundColor: scheme.onPrimaryContainer.withValues(
                alpha: 0.16,
              ),
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                info.curr?.name ?? '...',
                style: _labelStyle(textTheme, scheme),
              ),
              Text(next.name, style: _labelStyle(textTheme, scheme)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle? _labelStyle(TextTheme textTheme, ColorScheme scheme) {
    return textTheme.labelMedium?.copyWith(
      color: scheme.onPrimaryContainer.withValues(alpha: 0.65),
      fontWeight: FontWeight.w600,
    );
  }
}
