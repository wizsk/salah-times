import 'package:flutter/material.dart';
import 'package:salah_times/pages/salah_times_page.dart';
import 'package:salah_times/utils/open_location_change_page.dart';
import 'package:salah_times/utils/utils.dart';

const tzChangePopupIgnoreVale = 'ignore';

Future<String?> showTimeChangedSheet(BuildContext context) async {
  return showModalBottomSheet<String?>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: maxContentWidth,
    builder: (context) {
      return SingleChildScrollView(
        padding: scrollPaddingBottmSheet(context, sides: 24, bottomExtra: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your timezone may have changed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'It looks like your device’s timezone or location has changed. '
              'Prayer times may no longer be accurate.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    postFrame(() => showLocationProvidorScreen(context));
                  },
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('Change location'),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Do nothing, remind on next open just!
                  },
                  icon: const Icon(Icons.notifications_none_outlined),
                  label: const Text('Remind me later'),
                ),

                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context, tzChangePopupIgnoreVale);
                    // Ignore
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Ignore'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
