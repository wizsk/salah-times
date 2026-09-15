import 'package:flutter/material.dart';
import 'package:salah_times/services/app_conf.dart';

class ThemeSwicher extends StatefulWidget {
  const ThemeSwicher({super.key});

  @override
  State<ThemeSwicher> createState() => _ThemeSwicherState();
}

class _ThemeSwicherState extends State<ThemeSwicher> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.0,
        children: [
          _ThemeModeButton(
            icon: Icons.settings_suggest_rounded,
            label: 'System',
            selected: AppConf.theme == ThemeMode.system,
            onTap: () async {
              setState(() {
                AppConf.theme = ThemeMode.system;
              });
              //   await appConf.saveTheme(ThemeMode.system);
              //   if (context.mounted) setState(() {});
            },
          ),
          _ThemeModeButton(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            selected: AppConf.theme == ThemeMode.light,
            onTap: () async {
              setState(() {
                AppConf.theme = ThemeMode.light;
              });
            },
          ),
          _ThemeModeButton(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            selected: AppConf.theme == ThemeMode.dark,
            onTap: () async {
              setState(() {
                AppConf.theme = ThemeMode.dark;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: label,
      child: Material(
        color: selected ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 70,
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5.0,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
