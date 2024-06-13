import 'package:flutter/material.dart';
import 'package:voxiloud/pages/dashboard/home/home_page.dart';
import 'package:voxiloud/pages/dashboard/home/saved_page.dart';
import 'package:voxiloud/pages/dashboard/home/settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SavedPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(
              Icons.home_rounded,
              size: 26,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bookmark_rounded,
              size: 26,
            ),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_rounded,
              size: 26,
            ),
            label: 'Settings',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
