import 'package:flutter/widgets.dart';
import 'package:mynotes/utilities/dialogs/generics_dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context) async {
  return showGenericsDialog<void>(
      context: context,
      title: "Password Reset?",
      content: "We Send A Email To Your Email Check Your Email Now!",
      optionBuilder: () => {'Ok': null});
}
