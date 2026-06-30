import 'package:flutter/material.dart';
import 'home_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Wallet'))),
    const Scaffold(body: Center(child: Text('Swap'))),
    const Scaffold(body: Center(child: Text('Activity'))),
    const Scaffold(body: Center(child: Text('Browser'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2A2A2A),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
          _buildNavItem(1, Icons.account_balance_wallet, Icons.account_balance_wallet_outlined),
          _buildNavItem(2, Icons.swap_horiz, Icons.swap_horiz_outlined),
          _buildNavItem(3, Icons.chat_bubble, Icons.chat_bubble_outline),
          _buildNavItem(4, Icons.search, Icons.search_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFFA693F5) : const Color(0xFF6B6B6B);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}
