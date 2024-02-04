import 'package:flutter/material.dart';
import 'package:secure_note/data/note_repository.dart';
import 'package:secure_note/view/home/notes/note_edit_page.dart';

import '../../../model/note_item.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
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

  Widget _noteItem(NoteItem item) => SizedBox(
        height: 50,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(NoteEditPage.route(noteId: item.id));
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
              ],
            ),
          ),
        ),
      );
}
