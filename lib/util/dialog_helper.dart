import 'package:file_shield/main.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  static displayDialog({
    required BuildContext context,
    String? description,
    String? title,
    VoidCallback? onPressed,
    VoidCallback? cancelAction,
    String actionText = 'Okay',
    Widget? content,
  }) async {
    final ThemeData theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title ?? 'Operation failed',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.blue),
          ),
          content: content ??
              Text(
                description ?? 'Oops, something went wrong!',
                style: theme.textTheme.bodyLarge,
              ),
          actions: <Widget>[
            cancelAction != null
                ? TextButton(
                    onPressed: cancelAction,
                    style: TextButton.styleFrom(
                        textStyle: theme.textTheme.titleSmall
                            ?.copyWith(color: Colors.red)),
                    child: const Text('Back'),
                  )
                : const SizedBox(width: 2),
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }
}
