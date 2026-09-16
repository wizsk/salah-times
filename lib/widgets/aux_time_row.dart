import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/theme/app_theme.dart';
import 'package:salah_times/widgets/dialouges.dart';

/// The Imsak / Midnight row — smaller, outlined, secondary to the main
/// prayer list since these are auxiliary markers rather than prayers.
class AuxTimeRow extends StatelessWidget {
  const AuxTimeRow({super.key, required this.items});

  final PrayerDay items;

  @override
  Widget build(BuildContext context) {
    final use24h = MediaQuery.of(context).alwaysUse24HourFormat;
    return Row(
      spacing: 8.00,
      children: [
        ...items.timings.en
            .getRange(6, 8)
            .map(
              (e) => Expanded(
                child: _AuxChip(en: e, use24h: use24h),
              ),
            ),
      ],
    );
  }
}

class _AuxChip extends StatelessWidget {
  const _AuxChip({required this.en, required this.use24h});

  final PrayerTimingEntry en;
  final bool use24h;

  static final _borderRadius = BorderRadius.circular(20);

  @override
  Widget build(BuildContext context) {
    final (hm, amapm) = en.fmtHMAMPM(use24h);

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: _borderRadius,
            ),
            child: Icon(en.icon, size: 18, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    en.name,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: hm,
                    style: textTheme.titleSmall?.copyWith(
                      fontFamily: AppTheme.displayFont,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                    children: amapm.isEmpty
                        ? null
                        : [
                            TextSpan(
                              text: ' $amapm',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final info = en.info;
    return info == null
        ? child
        : InkWell(
            borderRadius: _borderRadius,
            child: child,
            onTap: () {
              showInfoDialog(context, 'Info', message: info, constraints: true);
            },
          );
  }
}
