import 'package:flutter/material.dart';

class MainBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabSelected;

  const MainBottomAppBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const SizedBox(width: 0),
            IconButton(
              icon: const Icon(Icons.home),
              color: currentIndex == 0 ? Color(0xFF43A047) : Colors.grey,
              onPressed: () => onTabSelected(0),
              tooltip: 'Home',
            ),
            const SizedBox(width: 0),
            IconButton(
              icon: const Icon(Icons.list_alt),
              color: currentIndex == 1 ? Color(0xFF43A047) : Colors.grey,
              onPressed: () => onTabSelected(1),
              tooltip: 'Lançamentos',
            ),
            const SizedBox(width: 0),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              color: currentIndex == 2 ? Color(0xFF43A047) : Colors.grey,
              onPressed: () => onTabSelected(2),
              tooltip: 'Contas',
            ),
            const SizedBox(width: 0),
          ],
        ),
      ),
    );
  }
} 