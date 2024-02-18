import 'package:rxdart/rxdart.dart';
import 'package:secure_note/api/api.dart';
import 'package:secure_note/data/notes/note_repository.dart';
import 'package:secure_note/model/note_full.dart';
import 'package:secure_note/model/note_item.dart';

class RestNoteRepository extends NoteRepository {
  final _reloadTasksCount = BehaviorSubject<int>.seeded(0);
  final _notes = BehaviorSubject<List<NoteItem>>.seeded([]);

  Future<T> _withReload<T>(Future<T> Function() operation) {
    _reloadTasksCount.add(_reloadTasksCount.value + 1);
    return operation().whenComplete(() {
      _reloadTasksCount.add(_reloadTasksCount.value - 1);
    });
  }

  @override
  Future<int> createNote({required String title, required String content}) {
    return _withReload(
      () => NotesApi.inst
          .notesPost(
        title: title,
        content: content,
      )
          .then(
        (resp) {
          reloadNoteList();
          return resp.item.id;
        },
      ),
    );
  }

  @override
  Future<void> deleteNotes({required List<int> ids}) {
    return _withReload(
      () => Future.wait(
        ids.map((id) => NotesApi.inst.noteDelete(id: id)).toList(),
      ),
    ).then(
      (resp) {
        reloadNoteList();
      },
    );
  }

  @override
  Future<NoteFull> getNote({required int id}) {
    return NotesApi.inst.notesGet(id: id).then(
          (resp) => NoteFull(
            id: resp.item.id,
            title: resp.item.title,
            content: resp.item.content,
          ),
        );
  }

  @override
  Stream<List<NoteItem>> getNoteList() => _notes;

  @override
  Stream<bool> isReloadingNoteList() {
    return _reloadTasksCount.map((c) => c > 0);
  }

  @override
  Future<void> reloadNoteList() {
    return _withReload(
      () => NotesApi.inst.notesGetAll().then(
        (resp) {
          _notes.add(
            resp.items
                .map(
                  (e) => NoteItem(
                    id: e.id,
                    title: e.title,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  @override
  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
  }) {
    return _withReload(
      () => NotesApi.inst
          .notesPatch(
        id: id,
        title: title,
        content: content,
      )
          .then(
        (resp) {
          reloadNoteList();
        },
      ),
    );
  }
}
