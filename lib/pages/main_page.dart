import 'package:flutter/material.dart';
import 'package:madcamp_lounge/tabs/party_tab.dart';
import 'package:madcamp_lounge/tabs/profile_tab.dart';
import 'package:madcamp_lounge/tabs/recommend_tab.dart';

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
      backgroundColor: Theme.of(context).primaryColor,
      body:Center(
        child: _tabs.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "파티 모집"),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "놀거리 추천"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "프로필"),
          ],
          selectedItemColor: Colors.purpleAccent,
          currentIndex: _selectedIndex,
          onTap: _onIconTapped,
        ),
      ),
    );
  }
}
