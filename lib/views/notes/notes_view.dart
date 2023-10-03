import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/crud/note_services.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'dart:developer' as devtools show log;

import '../../constans/routes.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NoteServices _noteServices;
  String get getUserEmail => AuthServices.firebase().currentUser!.email!;
  @override
  void initState() {
    _noteServices = NoteServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Page"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteView);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MainActivity>(
            onSelected: (value) async {
              switch (value) {
                case MainActivity.logout:
                  final logout = await showLogoutDialog(context);
                  devtools.log(logout.toString());
                  if (logout) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
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
      body: FutureBuilder(
        future: _noteServices.getOrCreateUser(email: getUserEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _noteServices.getUserAllNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allnotes = snapshot.data!;
                        return ListView.builder(
                          itemCount: allnotes.length,
                          itemBuilder: (context, index) {
                            final note = allnotes[index];
                            return ListTile(
                              title: Text(
                                note.text,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
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
