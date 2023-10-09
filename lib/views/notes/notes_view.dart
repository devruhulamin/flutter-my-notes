import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/crud/note_services.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/utilities/dialogs/show_log_out_dialog.dart';
import 'package:mynotes/views/notes/create_or_update_note.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
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
                Navigator.of(context).pushNamed(createOrUpdateNote);
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

                        return NoteListView(
                          onNoteTap: (note) {
                            Navigator.of(context)
                                .pushNamed(createOrUpdateNote, arguments: note);
                          },
                          notes: allnotes,
                          onDeleteNote: (note) async {
                            await _noteServices.deleteNote(id: note.id);
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