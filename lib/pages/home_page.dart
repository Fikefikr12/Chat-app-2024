import 'package:chatapp1/component/my_drawer.dart';
import 'package:chatapp1/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'chat_user_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages to show based on selected icon
  final List<Widget> _pages = [
    ChatUserListPage(),  // Chat user list page
    ProfilePage(),       // Profile page
  ];

  // Function to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
     drawer: MyDrawer(),
      // Show selected page based on the current index
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // This changes the view
      ),
    );
  }
}
