import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifiEmailPage extends StatelessWidget {
  const VerifiEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Verifi Your Email Now"),
        TextButton(
            onPressed: () async {
              final instance = FirebaseAuth.instance.currentUser;
              await instance?.sendEmailVerification();
            },
            child: const Text("Send Verfie Link"))
      ],
    );
  }
}
