import 'package:accounts/utility/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: "An error occurred",
    content: text,
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}

Future<void> showRerscuerDialog(
    BuildContext context, String textDes, String textTitle) {
  return showGenericDialog<void>(
    context: context,
    title: textTitle,
    content: textDes,
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}
