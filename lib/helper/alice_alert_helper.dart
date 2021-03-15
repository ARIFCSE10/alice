import 'package:flutter/material.dart';

class AliceAlertHelper {
  ///Helper method used to open alarm with given title and description.
  static void showAlert(
    BuildContext context,
    String title,
    String description, {
    String firstButtonTitle = "Accept",
    String? secondButtonTitle,
    Function? firstButtonAction,
    Function? secondButtonAction,
    Brightness? brightness,
  }) {
    assert(context != null, "context can't be null");
    assert(title != null, "title can't be null");
    assert(description != null, "description can't be null");
    final List<Widget> actions = [];
    if (firstButtonTitle != null) {
      actions.add(
        TextButton(
          onPressed: () {
            if (firstButtonAction != null) {
              firstButtonAction();
            }
            Navigator.of(context).pop();
          },
          child: Text(firstButtonTitle),
        ),
      );
    }
    if (secondButtonTitle != null) {
      actions.add(
        TextButton(
          onPressed: () {
            if (secondButtonAction != null) {
              secondButtonAction();
            }
            Navigator.of(context).pop();
          },
          child: Text(secondButtonTitle),
        ),
      );
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext buildContext) {
        return Theme(
          data: ThemeData(
            brightness: brightness ?? Brightness.light,
          ),
          child: AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: actions,
          ),
        );
      },
    );
  }
}
