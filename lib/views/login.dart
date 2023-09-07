import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mynotes/constans/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        title: const Text("Login"),
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
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, password: password);

                  final isVerified =
                      FirebaseAuth.instance.currentUser?.emailVerified ?? false;

                  if (context.mounted && isVerified) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } else if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        emailVerifyRoute, (route) => false);
                  }
                } on FirebaseAuthException catch (e) {
                  await showErrorDialog(
                    context,
                    e.code,
                  );
                } catch (e) {
                  await showErrorDialog(
                    context,
                    e.toString(),
                  );
                }
              },
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Don't Have An Account,Register")),
        ],
      ),
    );
  }
}
