import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constant.dart';

class CloudNote {
  final String text;
  final String ownerId;
  final String documentId;

  CloudNote(
      {required this.text, required this.ownerId, required this.documentId});

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerId = snapshot.data()[ownerUserIdFieldName] as String,
        text = snapshot.data()[textFieldname] as String;
}
