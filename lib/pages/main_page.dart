import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/chatting/state/chatting_state.dart';
import 'package:madcamp_lounge/features/chatting/ui/chatting_tab.dart';
import 'package:madcamp_lounge/features/party/ui/party_tab.dart';
import 'package:madcamp_lounge/features/profile/profile_tab.dart';
import 'package:madcamp_lounge/features/recommend/recommend_tab.dart';
import 'package:madcamp_lounge/features/recommend/state/recommend_providers.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerStatefulWidget {
  const MainPage({
    super.key,
    this.startIndex,
    this.showPasswordChangeDialog = false,
  });

  final int? startIndex;
  final bool showPasswordChangeDialog;

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  var _selectedIndex = 0;
  static const List<Widget> _tabs = <Widget>[
    PartyTab(),
    RecommendTab(),
    ChattingTab(),
    ProfileTab(),
  ];

  void _onIconTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      ref.read(chatTabRefreshTriggerProvider.notifier).state++;
    }
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startIndex ?? 0;
    Future.microtask(() {
      ref.read(allPlacesProvider.future);
      }
    );
    if (widget.showPasswordChangeDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('비밀번호 변경 권장'),
              content: const Text(
                '현재 비밀번호가 초기 비밀번호입니다.\n보안을 위해 비밀번호를 변경해주세요.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Theme(data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: "파티 모집"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_pin),
                label: "놀거리 추천"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: "채팅"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "프로필"
            ),
          ],
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w700,
          ),
          currentIndex: _selectedIndex,
          onTap: _onIconTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
