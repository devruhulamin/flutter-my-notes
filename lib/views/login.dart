import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

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
                  final usercreditails = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);
                  devtools.log(usercreditails.toString());
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil("/notes/", (route) => false);
                  }
                } on FirebaseAuthException catch (e) {
                  devtools.log(e.toString());
                }
              },
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/register/", (route) => false);
              },
              child: const Text("Don't Have An Account,Register")),
        ],
      ),
    );
  }
}
