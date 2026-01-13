import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/chatting/ui/chatting_tab.dart';
import 'package:madcamp_lounge/features/party/ui/party_tab.dart';
import 'package:madcamp_lounge/features/profile/profile_tab.dart';
import 'package:madcamp_lounge/features/recommend/recommend_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: _tabs.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                label: "파티 모집"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: "놀거리 추천"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: "채팅"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "프로필"
            ),
          ],
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          currentIndex: _selectedIndex,
          onTap: _onIconTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
