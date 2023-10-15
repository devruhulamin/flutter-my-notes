import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateOrUpdateNote extends StatefulWidget {
  const CreateOrUpdateNote({super.key});

  @override
  State<CreateOrUpdateNote> createState() => _CreateOrUpdateNoteState();
}

class _CreateOrUpdateNoteState extends State<CreateOrUpdateNote> {
  CloudNote? _note;
  late final FirebaseCloudStorage _noteServices;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _noteServices = FirebaseCloudStorage();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _texeditingControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;

    await _noteServices.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTexeditingControllerListener() {
    _textEditingController.removeListener(_texeditingControllerListener);
    _textEditingController.addListener(_texeditingControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final existingNote = _note;
    final widgetNote = context.getArguments<CloudNote>();
    if (widgetNote != null) {
      _textEditingController.text = widgetNote.text;
      _note = widgetNote;
      return widgetNote;
    }
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthServices.firebase().currentUser!;
    final newNote =
        await _noteServices.createNewNote(ownerUserId: currentUser.id);
    _note = newNote;
    return newNote;
  }

  void deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      await _noteServices.deleteNote(documentId: note.documentId);
    }
  }

  void saveNoteIfTextIsNotEmpty() async {
    final note = _note;

    final text = _textEditingController.text;
    if (text.isNotEmpty && note != null) {
      await _noteServices.updateNote(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() async {
    deleteNoteIfTextIsEmpty();
    saveNoteIfTextIsNotEmpty();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // _note = snapshot.data;
              _setupTexeditingControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Enter Your note here........",
                ),
                maxLength: null,
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
