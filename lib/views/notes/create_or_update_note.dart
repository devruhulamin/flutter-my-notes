import 'package:flutter/material.dart';
import 'package:mynotes/crud/note_services.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateOrUpdateNote extends StatefulWidget {
  const CreateOrUpdateNote({super.key});

  @override
  State<CreateOrUpdateNote> createState() => _CreateOrUpdateNoteState();
}

class _CreateOrUpdateNoteState extends State<CreateOrUpdateNote> {
  DatabaseNote? _note;
  late final NoteServices _noteServices;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _noteServices = NoteServices();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _texeditingControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;

    await _noteServices.updateNote(note: note, text: text);
  }

  void _setupTexeditingControllerListener() {
    _textEditingController.removeListener(_texeditingControllerListener);
    _textEditingController.addListener(_texeditingControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final existingNote = _note;
    final widgetNote = context.getArguments<DatabaseNote>();
    if (widgetNote != null) {
      _textEditingController.text = widgetNote.text;
      _note = widgetNote;
      return widgetNote;
    }
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteServices.getUser(email: email);
    final newNote = await _noteServices.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      await _noteServices.deleteNote(id: note.id);
    }
  }

  void saveNoteIfTextIsNotEmpty() async {
    final note = _note;

    final text = _textEditingController.text;
    if (text.isNotEmpty && note != null) {
      await _noteServices.updateNote(note: note, text: text);
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
