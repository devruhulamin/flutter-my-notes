import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generics_dialog.dart';

Future<void> showCanNotShareEmptyNoteDialog(BuildContext context) async {
  return await showGenericsDialog<void>(
    context: context,
    title: "Sharing",
    content: "Can not share empty note!..",
    optionBuilder: () => {'ok': null},
  );
}
