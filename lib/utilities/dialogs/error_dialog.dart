import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generics_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericsDialog<void>(
      context: context,
      title: "An Error Occur",
      content: text,
      optionBuilder: () => {
            "Ok": null,
          });
}
