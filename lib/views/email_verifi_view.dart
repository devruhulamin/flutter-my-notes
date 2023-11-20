import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

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
              onPressed: () {
                context.read<AuthBloc>().add(AuthEventSendEmailVerification());
              },
              child: const Text("Resend Email")),
          TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogout());
              },
              child: const Text("Restart"))
        ],
      ),
    );
  }
}
