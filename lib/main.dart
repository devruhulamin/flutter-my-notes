import 'package:flutter/material.dart';
import 'package:mynotes/constans/routes.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/views/email_verifi_view.dart';
import 'package:mynotes/views/login.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/registraion.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 33, 239)),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginPage(),
      registerRoute: (context) => const Registration(),
      notesRoute: (context) => const NotesPage(),
      emailVerifyRoute: (context) => const VerifiEmailPage()
    },
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return FutureBuilder(
      future: AuthServices.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthServices.firebase().currentUser;
            if (user != null) {
              if (user.isEmailverified) {
                return const NotesPage();
              }
              return const VerifiEmailPage();
            } else {
              return const LoginPage();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
