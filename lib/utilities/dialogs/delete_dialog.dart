import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generics_dialog.dart';

Future<bool> showDeleteNoteDialog(BuildContext context) {
  return showGenericsDialog<bool>(
    context: context,
    title: "Deleting Note",
    content: "Are You Sure Want to Delete?",
    optionBuilder: () => {
      "Cancel": false,
      "Yap!": true,
    },
  ).then((value) => value ?? false);
}
