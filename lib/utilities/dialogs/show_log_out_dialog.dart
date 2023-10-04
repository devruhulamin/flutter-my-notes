import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generics_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericsDialog<bool>(
    context: context,
    title: "Log Out",
    content: "Are You Sure Want to Logout?",
    optionBuilder: () => {
      "Cancel": false,
      "Logout": true,
    },
  ).then((value) => value ?? false);
}
