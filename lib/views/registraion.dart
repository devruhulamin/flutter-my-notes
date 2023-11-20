import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is EmailAlreadyInUseException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Email Already Haven An Account!",
            );
          } else if (state.exception is InvalidEmailException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Email is not Valid",
            );
          } else if (state.exception is WeakPasswordException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Password is Weak Give Password 6 char long",
            );
          } else if (state.exception is GenericsAuthException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Fail To Register ",
            );
          }
        }
      },
      child: Scaffold(
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
                onPressed: () {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(
                      AuthEventRegisterUser(email: email, password: password));
                },
                child: const Text("Register")),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
                child: const Text("Already Have An Account,Login")),
          ],
        ),
      ),
    );
  }
}
