import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/show_password_reset_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateResetPassword) {
          if (state.hasSentEmail) {
            await showPasswordResetDialog(context);
            _emailController.clear();
          }
          if (state.exception != null && mounted) {
            await showErrorDialog(
                context, 'Something Went Wrong While Proccess Your Request');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Forgot Password")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                  'if you want Reset your Password Then Enter Your Email'),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'Enter Your Email...'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventResetPassword());
                },
                child: const Text("Send Link To Email"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
                child: const Text("Back to login page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
