import 'dart:async';

import 'package:secure_note/data/notes/rest_note_repository.dart';
import 'package:secure_note/model/note_item.dart';

import '../../model/note_full.dart';
import 'local_note_repository.dart';

abstract class NoteRepository {
  Future<void> reloadNoteList();

  Future<NoteFull?> getNote({required int id});

  Stream<List<NoteItem>> getNoteList();

  Stream<bool> isReloadingNoteList();

  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
  });

  Future<void> deleteNotes({required List<int> ids});

  Future<int> createNote({
    required String title,
    required String content,
  });

  static final inst = RestNoteRepository();
}
