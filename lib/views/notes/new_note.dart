import 'package:flutter/material.dart';
import 'package:mynotes/crud/note_services.dart';
import 'package:mynotes/services/auth/auth_services.dart';

class NewNote extends StatefulWidget {
  const NewNote({super.key});

  @override
  State<NewNote> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
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

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteServices.getUser(email: email);
    final newNote = await _noteServices.createNote(owner: owner);
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
  void dispose() {
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
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data;
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
