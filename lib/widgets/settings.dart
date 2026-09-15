import 'package:flutter/material.dart';

enum SettingsSectionSurfaceMode { normal, alert }

class SettingsSectionSurface extends StatelessWidget {
  final List<Widget> children;
  final SettingsSectionSurfaceMode mode;

  const SettingsSectionSurface({
    super.key,
    required this.children,
    this.mode = SettingsSectionSurfaceMode.normal,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = mode == SettingsSectionSurfaceMode.normal
        ? cs.surfaceContainer
        : cs.errorContainer;
    final tint = cs.surfaceTint;

    return Material(
      color: color,
      surfaceTintColor: tint,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _withDividers(children),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> children) {
    if (children.isEmpty) return [];

    return List.generate(children.length * 2 - 1, (i) {
      if (i.isEven) return children[i ~/ 2];
      return const Divider(height: 0, thickness: 0.6);
    });
  }
}

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ReaderSelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final IconData trailing;
  final FilledIconVariant variant;

  const ReaderSelectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.trailing = Icons.chevron_right,
    this.variant = FilledIconVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FilledIcon(icon, variant: variant),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(trailing),
      onTap: () => Navigator.pop(context, value),
    );
  }
}

enum FilledIconVariant { /* neutral, */ primary, secondary, error }

class FilledIcon extends StatelessWidget {
  final IconData icon;
  final FilledIconVariant variant;
  final double size;
  final bool outlined;

  const FilledIcon(
    this.icon, {
    super.key,
    this.variant = FilledIconVariant.primary,
    this.size = 20,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, fg) = switch (variant) {
      FilledIconVariant.primary => (cs.primary, cs.onPrimary),
      FilledIconVariant.secondary => (cs.secondary, cs.onSecondary),
      FilledIconVariant.error => (cs.error, cs.onError),
      // FilledIconVariant.neutral => (
      //   cs.surfaceContainerHighest,
      //   cs.onSurfaceVariant,
      // ),
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: outlined
            ? Border.all(color: cs.outlineVariant, width: 1)
            : null,
      ),
      child: Icon(icon, size: size, color: fg),
    );
  }
}
