import 'package:flutter/material.dart';

Future<bool?> showInfoDialog(
  BuildContext context,
  String title, {
  String? message,
  String confirmText = 'Okay',
  TextDirection dir = TextDirection.ltr,
  bool constraints = false,
  bool distructive = false,
  bool useLClass = false,
  String? fontFam,
  bool scroolable = false,
}) async {
  return showConfirmDialog(
    context,
    title,
    message: message,
    dir: dir,
    confirmText: confirmText,
    cancelText: null,
    constraints: constraints,
    destructive: distructive,
    fontFam: fontFam,
    scroolable: scroolable,
  );
}

/// if [useLClass] == true [dir], [fontFam] will be ignored
Future<bool?> showConfirmDialog(
  BuildContext context,
  String title, {
  String? message,
  String confirmText = 'Confirm',
  String? cancelText = 'Cancel',
  bool destructive = false,
  TextDirection dir = TextDirection.ltr,
  bool constraints = false,
  String? fontFam,
  bool scroolable = false,
  bool autofocusConfirm = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final cs = theme.colorScheme;

      return AlertDialog(
        scrollable: scroolable,
        constraints: constraints ? const BoxConstraints(maxWidth: 450) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // M3 style
        ),
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: cs.surfaceTint,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

        title: Text(
          title,
          textDirection: dir,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: fontFam,
            // color: cs.onSurfaceVariant,
          ),
        ),

        content: message != null
            ? Text(
                message,
                textDirection: dir,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontFamily: fontFam,
                ),
              )
            : null,

        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelText,
                textDirection: dir,
                style: fontFam == null ? null : TextStyle(fontFamily: fontFam),
              ),
            ),

          FilledButton(
            autofocus: autofocusConfirm,
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? cs.error : null,
              foregroundColor: destructive ? cs.onError : null,
            ),
            child: Text(
              confirmText,
              textDirection: dir,
              style: TextStyle(fontFamily: fontFam),
            ),
          ),
        ],
      );
    },
  );
}
