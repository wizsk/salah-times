import 'package:flutter/material.dart';
import 'package:salah_times/models/prayer_times_modifiers.dart';
import 'package:salah_times/pages/salah_times_page.dart';
import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/utils/utils.dart';

Future<void> showPrayerSchoolPicker(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: maxContentWidth,
    builder: (_) => _PrayerMethodSheet(
      curr: AppConf.school,
      values: PrayerSchool.values,
      def: () => PrayerSchool.usingDef,
      reset: () => AppConf.school = PrayerSchool.def,
      save: (v) {
        AppConf.school = v as PrayerSchool;
      },
      searchHintTxt: 'Search Schools',
      title: 'Calculation School',
      subtitle: 'Choose how prayer times are calculated',
    ),
  );
}

Future<void> showPrayerMethodPicker(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: maxContentWidth,
    builder: (_) => _PrayerMethodSheet(
      curr: AppConf.method,
      values: PrayerMethod.values,
      def: () => PrayerMethod.usingDef,
      reset: () => AppConf.method = PrayerMethod.def,
      save: (v) {
        AppConf.method = v as PrayerMethod;
      },
      searchHintTxt: 'Search methods',
      title: 'Calculation method',
      subtitle: 'Choose how prayer times are calculated',
    ),
  );
}

class _PrayerMethodSheet extends StatefulWidget {
  const _PrayerMethodSheet({
    required this.curr,
    required this.values,
    required this.def,
    required this.reset,
    required this.save,
    required this.title,
    required this.subtitle,
    required this.searchHintTxt,
  });

  final PrayerMods curr;
  final List<PrayerMods> values;
  final bool Function() def;
  final VoidCallback reset;
  final void Function(PrayerMods) save;
  final String title;
  final String subtitle;
  final String searchHintTxt;

  @override
  State<_PrayerMethodSheet> createState() => _PrayerMethodSheetState();
}

class _PrayerMethodSheetState extends State<_PrayerMethodSheet> {
  final _searchController = TextEditingController();

  String get query => _searchController.text.trim().toLowerCase();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _set(PrayerMods m) {
    widget.save(m);
  }

  bool _def() {
    return widget.def();
  }

  void _reset() {
    widget.reset();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final child = DraggableScrollableSheet(
      expand: false,
      initialChildSize: .65,
      minChildSize: .4,
      maxChildSize: .95,
      builder: (context, scrollController) {
        final methods = widget.values.where((method) {
          return method.name.toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.restore),
                        onPressed: _def()
                            ? null
                            : () {
                                _reset();
                              },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Flat SearchBar — no shadow.
                  SearchBar(
                    controller: _searchController,
                    hintText: widget.searchHintTxt,
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      scheme.surfaceContainerHighest,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: methods.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final method = methods[index];
                  final selected = method == widget.curr;

                  return Material(
                    color: selected
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        _set(method);
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? scheme.secondary
                                : scheme.surfaceContainerHighest,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: selected
                                      ? scheme.onSecondary
                                      : scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        title: Text(
                          method.name,
                          style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: selected
                            ? Icon(Icons.check_circle, color: scheme.primary)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    return Padding(
      padding: scrollPaddingBottmSheet(context, sides: 20),
      child: child,
    );
  }
}
