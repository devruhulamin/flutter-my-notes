import 'package:flutter/material.dart';
import 'package:mynotes/constans/routes.dart';
import 'package:mynotes/services/auth/auth_services.dart';

class VerifiEmailPage extends StatelessWidget {
  const VerifiEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Text("We Have Send You a Verify Link In your Email Address"),
          const Text(
              "Please Verify Your Email Address by Clicking on the link"),
          TextButton(
              onPressed: () async {
                await AuthServices.firebase().sendEmailVerification();
              },
              child: const Text("Resend Email")),
          TextButton(
              onPressed: () async {
                await AuthServices.firebase().logout();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
              },
              child: const Text("Restart"))
        ],
      ),
    );
  }
}
