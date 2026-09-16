import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/pages/salah_times_page.dart';
import 'package:salah_times/utils/utils.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    constraints: maxContentWidth,
    builder: (context) {
      return Padding(
        padding: scrollPaddingBottmSheet(context, sides: 20, bottomExtra: 12),
        child: RadioGroup<L>(
          groupValue: L.curr,
          onChanged: (value) {
            if (value == null) return;

            L.curr = value;
            Navigator.pop(context);
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Language', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Select the language in which prayer names will be shown.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Divider(),

              for (final lang in L.values)
                ListTile(
                  leading: Radio<L>(value: lang),
                  title: Text(lang.name),
                  subtitle: lang.nameLn == null ? null : Text(lang.nameLn!),
                  onTap: () {
                    L.curr = lang;
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
