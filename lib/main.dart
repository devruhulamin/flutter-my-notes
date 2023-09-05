import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/email_verifi_view.dart';
import 'package:mynotes/views/login.dart';
import 'package:mynotes/views/registraion.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

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
      "/login/": (context) => const LoginPage(),
      "/register/": (context) => const Registration(),
      "/notes/": (context) => const NotesPage(),
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
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            user?.reload();
            final isEmailVerified = user?.emailVerified ?? false;
            if (user != null) {
              if (isEmailVerified) {
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

enum MainActivity { logout }

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Page"),
        actions: [
          PopupMenuButton<MainActivity>(
            onSelected: (value) async {
              switch (value) {
                case MainActivity.logout:
                  final logout = await showLogoutDialog(context);
                  devtools.log(logout.toString());
                  if (logout) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil("/login/", (route) => false);
                    }
                  }
                  break;
              }
              devtools.log(value.toString());
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MainActivity.logout,
                  child: Text("Logout"),
                ),
              ];
            },
          )
        ],
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are You Sure Want To,Logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
