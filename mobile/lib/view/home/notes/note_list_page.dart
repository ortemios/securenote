import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_note/data/note_repository.dart';
import 'package:secure_note/view/home/notes/note_edit_page.dart';

import '../../../model/note_item.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final _selectedIds = <int>{};
  late StreamSubscription _noteListSub;

  @override
  void initState() {
    _noteListSub = NoteRepository.inst.getNoteList().listen((event) {
      setState(() {
        _selectedIds.clear();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _noteListSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: NoteRepository.inst.isReloadingNoteList(),
          builder: (context, snapshot) {
            if (snapshot.data ?? true) {
              return const CircularProgressIndicator();
            } else {
              return StreamBuilder(
                stream: NoteRepository.inst.getNoteList(),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  if (items.isNotEmpty) {
                    return _list(items);
                  } else {
                    return const Text("Список пуст...");
                  }
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(NoteEditPage.route());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _list(List<NoteItem> items) {
    return Column(
      children: [
        if (_selectedIds.isNotEmpty)
          SizedBox(
            height: 50,
            child: Row(
              children: [
                MaterialButton(
                  onPressed: () {
                    NoteRepository.inst.deleteNotes(ids: _selectedIds.toList());
                  },
                  child: const Text("Удалить"),
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      _selectedIds.clear();
                    });
                  },
                  child: const Text("Отмена"),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) => _noteItem(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _noteItem(NoteItem item) {
    final isSelected = _selectedIds.contains(item.id);
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: () {
          if (_selectedIds.isNotEmpty) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(item.id);
              } else {
                _selectedIds.add(item.id);
              }
            });
          } else {
            Navigator.of(context).push(NoteEditPage.route(noteId: item.id));
          }
        },
        onLongPress: () {
          if (_selectedIds.isEmpty) {
            setState(() {
              _selectedIds.add(item.id);
              HapticFeedback.lightImpact();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 20,
                  ),
                ),
              // Container(
              //   color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              //   padding: const EdgeInsets.all(8.0),
              //   width: 10,
              //   height: 10,
              //   child: Icon(Icons.check_box),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
