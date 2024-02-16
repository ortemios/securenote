import 'package:flutter/material.dart';
import 'package:secure_note/data/notes/note_repository.dart';
import 'package:secure_note/view/home/notes/note_list_page.dart';
import 'package:secure_note/view/home/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(builder: (_) => const HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController();

  final _subtrees = <_Subtree>[
    const _Subtree(
      title: "Заметки",
      icon: Icons.list,
      initialRoute: NoteListPage(),
    ),
    const _Subtree(
      title: "Профиль",
      icon: Icons.person,
      initialRoute: ProfilePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    NoteRepository.inst.reloadNoteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: _subtrees.length,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SafeArea(
                child: PageView(
                  controller: _pageController,
                  children: _subtrees,
                ),
              ),
            ),
            TabBar(
              tabs: _subtrees.map(_tab).toList(),
              onTap: (index) => _pageController.jumpToPage(index),
            ),
          ],
        ),
      ),
    );
  }

  Tab _tab(_Subtree subtree) {
    return Tab(
      text: subtree.title,
      icon: Icon(subtree.icon),
    );
  }
}

class _Subtree extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget initialRoute;

  const _Subtree({
    required this.title,
    required this.icon,
    required this.initialRoute,
  });

  @override
  State<_Subtree> createState() => _SubtreeState();
}

class _SubtreeState extends State<_Subtree> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => widget.initialRoute),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
