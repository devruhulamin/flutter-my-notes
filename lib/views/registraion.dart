import 'package:flutter/material.dart';

import 'package:mynotes/constans/routes.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: "Enter Your Email",
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              hintText: "Enter Your Password",
            ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextButton(
              onPressed: () async {
                try {
                  final email = _email.text;
                  final password = _password.text;
                  await AuthServices.firebase()
                      .createUser(email: email, password: password);
                  await AuthServices.firebase().sendEmailVerification();
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(emailVerifyRoute);
                  }
                } on EmailAlreadyInUseException {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Email Already Haven An Account!",
                  );
                } on InvalidEmailException {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Email is not Valid",
                  );
                } on WeakPasswordException {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Password is Weak Give Password 6 char long",
                  );
                }
              },
              child: const Text("Register")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Already Have An Account,Login")),
        ],
      ),
    );
  }
}
