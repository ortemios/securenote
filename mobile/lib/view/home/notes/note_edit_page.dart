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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isModified = false;

  int? noteId;

  @override
  void initState() {
    super.initState();

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
          _isModified = false;
        }),
      );
    } else {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _header,
            _title,
            _content,
          ],
        ),
      ),
    );
  }

  Widget get _header {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _back,
          _actionIcon,
        ],
      ),
    );
  }

  Widget get _back {
    return IconButton(
      iconSize: 20,
      icon: const Icon(
        Icons.arrow_back_rounded,
        size: 20,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  
  Widget get _title {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _titleController,
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Заголовок не может быть пустым';
                }
                return null;
              },
              onChanged: _onTextChanged,
              decoration: const InputDecoration(hintText: 'Заголовок'),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _content {
    return SingleChildScrollView(
      child: TextFormField(
        controller: _contentController,
        maxLines: null,
        decoration: const InputDecoration(hintText: 'Содержимое'),
        onChanged: _onTextChanged,
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


  void _onTextChanged(String? value) {
    setState(() {
      _isModified = true;
    });
  }

  void _save() {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
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
            () =>
            setState(() {
              _isSaving = false;
            }),
      );
    }
  }
}
