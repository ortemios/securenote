import 'dart:convert';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/note_full.dart';
import '../../model/note_item.dart';
import 'note_repository.dart';

class LocalNoteRepository extends NoteRepository {
  final _isReloading = BehaviorSubject<bool>();
  final _notes = BehaviorSubject<List<NoteItem>>();

  @override
  Future<NoteFull?> getNote({required int id}) {
    return _readNotes().then(
      (items) => items.entries
          .map((e) => e.value)
          .map(
            (e) => NoteFull(
              id: e['id'] ?? 0,
              title: e['title'] ?? '',
              content: e['content'] ?? '',
            ),
          )
          .where((element) => element.id == id)
          .firstOrNull,
    );
  }

  @override
  Future<void> reloadNoteList() async {
    _isReloading.add(true);
    final notes = await _readNotes()
        .then(
          (items) => items.entries
              .map((e) => e.value)
              .map(
                (e) => NoteItem(
                  id: e['id'] ?? 0,
                  title: e['title'] ?? '',
                ),
              )
              .toList(),
        )
        .whenComplete(() => _isReloading.add(false));
    _notes.add(notes);
  }

  @override
  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
  }) async {
    var notes = await _readNotes();
    notes[id.toString()] = {
      'id': id,
      'title': title,
      'content': content,
    };
    await _writeNotes(notes);
    reloadNoteList();
  }

  @override
  Future<void> deleteNotes({required List<int> ids}) async {
    _notes.add(_notes.value.where((e) => !ids.contains(e.id)).toList());
    var notes = await _readNotes();
    for (final id in ids) {
      notes.remove(id.toString());
    }
    await _writeNotes(notes);
  }

  @override
  Future<int> createNote({required String title, required String content}) async {
    var notes = await _readNotes();
    final keys = notes.keys.map((e) => int.tryParse(e) ?? 0);
    final id = keys.isEmpty ? 0 : keys.reduce(max) + 1;
    await updateNote(id: id, title: title, content: content);
    return id;
  }

  @override
  Stream<List<NoteItem>> getNoteList() {
    return _notes.stream;
  }

  @override
  Stream<bool> isReloadingNoteList() {
    return _isReloading.stream;
  }

  final _notesKey = "notes";

  Future<Map<String, dynamic>> _readNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 300));
    final json = prefs.getString(_notesKey) ?? "{}";
    return jsonDecode(json);
  }

  Future<void> _writeNotes(Map<String, dynamic> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 300));
    final json = jsonEncode(notes);
    await prefs.setString(_notesKey, json);
  }
}
