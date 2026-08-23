import 'package:flutter/material.dart';

Future<bool?> showInfoDialog(
  BuildContext context,
  String title, {
  String? message,
  String confirmText = 'Okay',
  TextDirection dir = TextDirection.ltr,
  bool constraints = false,
  bool distructive = false,
}) async {
  return showConfirmDialog(
    context,
    title,
    message: message,
    dir: dir,
    confirmText: confirmText,
    cancelText: null,
    constraints: constraints,
    distructive: distructive,
  );
}

Future<bool?> showConfirmDialog(
  BuildContext context,
  String title, {
  String? message,
  String confirmText = 'Confirm',
  String? cancelText = 'Cancel',
  bool distructive = false,
  TextDirection dir = TextDirection.ltr,
  bool constraints = false,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final cs = theme.colorScheme;

      return AlertDialog(
        constraints: constraints ? const BoxConstraints(maxWidth: 450) : null,
        backgroundColor: cs.surface,
        title: Text(
          title,
          style: theme.textTheme.titleLarge,
          textDirection: dir,
        ),
        content: message == null
            ? null
            : Text(
                message,
                style: theme.textTheme.bodyMedium,
                textDirection: dir,
              ),
        actions: [
          if (cancelText != null)
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: distructive
                ? FilledButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                    // textStyle: TextStyle(color: cs.onError),
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}
