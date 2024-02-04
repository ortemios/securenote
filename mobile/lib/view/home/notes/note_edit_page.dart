import 'package:flutter/material.dart';
import 'package:secure_note/data/note_repository.dart';

class NoteEditPage extends StatefulWidget {
  final int? noteId;

  static MaterialPageRoute route({int? noteId}) => MaterialPageRoute(
        builder: (_) => NoteEditPage(noteId: noteId),
      );

  const NoteEditPage({
    super.key,
    this.noteId,
  });

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isModified = true;

  int? noteId;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChange);
    _contentController.addListener(_onChange);

    final noteId = widget.noteId;
    this.noteId = noteId;
    if (noteId != null) {
      NoteRepository.inst.getNote(id: noteId).then((note) {
        if (note != null) {
          _titleController.text = note.title;
          _contentController.text = note.content;
        }
      }).whenComplete(
        () => setState(() {
          _isLoading = false;
        }),
      );
    } else {
      _isLoading = false;
    }
  }

  void _onChange() {
    setState(() {
      _isModified = true;
    });
  }

  void _save() {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _isModified = false;
    });
    final title = _titleController.text;
    final content = _contentController.text;
    final id = noteId;
    final Future<void> operation;
    if (id != null) {
      operation = NoteRepository.inst.updateNote(id: id, title: title, content: content);
    } else {
      operation = NoteRepository.inst.createNote(title: title, content: content).then((id) => noteId = id);
    }
    operation.whenComplete(
      () => setState(() {
        _isSaving = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _titleController)),
                _actionIcon,
              ],
            ),
          ),
          SingleChildScrollView(
            child: TextField(
              controller: _contentController,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _actionIcon {
    const size = 20.0;
    return _isSaving
        ? const SizedBox(width: size, height: size, child: Center(child: CircularProgressIndicator()))
        : _isModified
            ? IconButton(
                iconSize: size,
                icon: const Icon(
                  Icons.save,
                  size: size,
                ),
                onPressed: _save,
              )
            : Container();
  }
}
