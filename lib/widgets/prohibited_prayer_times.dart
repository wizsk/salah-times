import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/utils/number.dart';

class PrayerWarning {
  final String title;
  final List<String> times;

  const PrayerWarning({required this.title, required this.times});
}

PrayerWarning prayerWarning() {
  return switch (L.curr) {
    L.en => const PrayerWarning(
      title: 'Prohibited prayer times',
      times: [
        '15 minutes after sunrise',
        '5 minutes before Zuhr',
        '15 minutes before sunset (that day’s Asr may still be prayed if due)',
      ],
    ),
    L.bn => const PrayerWarning(
      title: 'নিষিদ্ধ সময়',
      times: [
        'সূর্যোদয়ের পর ১৫ মিনিট',
        'যুহরের ওয়াক্তের পূর্বে ৫ মিনিট',
        'সূর্যাস্তের পূর্বে ১৫ মিনিট (চলতি দিনের আছর বাকি থাকলে পড়া যাবে)',
      ],
    ),
  };
}

class ProhibitedPrayerTimes extends StatelessWidget {
  const ProhibitedPrayerTimes(this.data, {super.key});
  final PrayerWarning data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final th = theme.textTheme;
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, size: 22, color: cs.error),
              const SizedBox(width: 8),
              Text(
                data.title,
                style: th.titleMedium?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...data.times.indexed.map((entry) {
            final (i, text) = entry;
            final bullet = switch (L.curr) {
              L.en => (i + 1).toString(),
              L.bn => (i + 1).bn,
            };

            return Padding(
              padding: EdgeInsets.only(
                bottom: i == data.times.length - 1 ? 0 : 8,
              ),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      bullet,
                      style: th.labelMedium?.copyWith(
                        color: cs.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: th.bodyLarge?.copyWith(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:salah_times/models/prayer_day.dart';
//
// class PrayerWarning {
//   final String label;
//   final List<({String icon, String text})> times;
//
//   const PrayerWarning({required this.label, required this.times});
// }
//
// PrayerWarning prayerWarning() {
//   return switch (L.curr) {
//     L.en => const PrayerWarning(
//       label: 'Prohibited prayer times:',
//       times: [
//         (icon: '1', text: '15 minutes after sunrise'),
//         (icon: '2', text: '5 minutes before Zuhr'),
//         (
//           icon: '3',
//           text: '15 minutes before sunset, but the day’s Asr prayer may be performed if it remains due.',
//         ),
//       ],
//     ),
//
//     L.bn => const PrayerWarning(
//       label: 'নিষিদ্ধ ৩ সময়:',
//       times: [
//         (icon: '১', text: 'সূর্যোদয়ের থেকে ১৫ মিনিট'),
//         (icon: '২', text: 'যুহরের ওয়াক্তের পূর্বে ৫ মিনিট'),
//         (
//           icon: '৩',
//           text: 'সূর্যাস্তের পূর্বে ১৫ মিনিট, তবে চলতি দিনের আসর নামাজ বাকি থাকলে পড়ে নিতে হবে।',
//         ),
//       ],
//     ),
//   };
// }
//
// class ProhibitedPrayerTimes extends StatelessWidget {
//   const ProhibitedPrayerTimes(this.data, {super.key});
//   final PrayerWarning data;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final th = theme.textTheme;
//     final cs = theme.colorScheme;
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Expanded(
//           child: Text.rich(
//             style: th.bodyLarge?.copyWith(height: 1.8),
//             TextSpan(
//               children: [
//                 TextSpan(
//                   text: '${data.label} ',
//                   style: TextStyle(
//                     color: cs.error,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 ...data.times.map((e) {
//                   return TextSpan(
//                     children: [
//                       WidgetSpan(
//                         alignment: PlaceholderAlignment.middle,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 1,
//                           ),
//                           decoration: BoxDecoration(
//                             color: cs.primary,
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Text(
//                             e.icon,
//                             style: th.bodyLarge?.copyWith(
//                               color: cs.onPrimary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextSpan(text: ' ${e.text} '),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
