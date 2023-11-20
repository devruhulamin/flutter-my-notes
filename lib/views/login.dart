import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constans/routes.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/loading_dialogs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? closeDialogHandler;
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
        if (state is AuthStateLoggenOut) {
          final closeDialog = closeDialogHandler;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            closeDialogHandler = null;
          } else if (state.isLoading && closeDialog == null) {
            closeDialogHandler =
                showLoadingDialog(context: context, text: 'Loading.....');
          }

          if (state.exception is WrongPasswordException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Given Password is Wrong!!",
            );
          } else if (state.exception is InvalidEmailException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Email is Invalid",
            );
          } else if (state.exception is UserNotFoundException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "User Not Found",
            );
          } else if (state is GenericsAuthException) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(
              context,
              "Something Went Wrong",
            );
          }
        }
      },
      child: Scaffold(
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
                onPressed: () {
                  final email = _email.text;
                  final password = _password.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventLogin(email: email, password: password));
                },
                child: const Text("Login")),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text("Don't Have An Account,Register")),
          ],
        ),
      ),
    );
  }
}
