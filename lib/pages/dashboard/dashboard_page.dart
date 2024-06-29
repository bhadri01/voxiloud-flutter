import 'package:flutter/material.dart';
import 'package:Voxiloud/pages/ads/ads.dart';
import 'package:Voxiloud/pages/dashboard/home/home_page.dart';
import 'package:Voxiloud/pages/dashboard/home/saved_page.dart';
import 'package:Voxiloud/pages/dashboard/home/settings_page.dart';

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
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: _widgetOptions,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            height: 60,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: Icon(
                  Icons.home_rounded,
                  size: 26,
                  color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : null,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.bookmark_rounded,
                  size: 26,
                  color: _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : null,
                ),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings_rounded,
                  size: 26,
                  color: _selectedIndex == 2 ? Theme.of(context).colorScheme.primary : null,
                ),
                label: 'Settings',
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
          ),
          const BannerAdWidget(), // Add BannerAdWidget below the NavigationBar
        ],
      ),
    );
  }
}
