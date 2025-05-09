import 'package:flutter/material.dart';

class MainBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabSelected;
  final bool showMetrics;

  const MainBottomAppBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    this.showMetrics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 16,
      shadowColor: Colors.black26,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100]?.withOpacity(0.97),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              color: currentIndex == 0 ? Color(0xFF43A047) : Colors.grey,
              onPressed: () => onTabSelected(0),
              tooltip: 'Home',
            ),
            IconButton(
              icon: const Icon(Icons.list_alt),
              color: currentIndex == 1 ? Color(0xFF43A047) : Colors.grey,
              onPressed: () => onTabSelected(1),
              tooltip: 'Lançamentos',
            ),
            SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                color: currentIndex == 2 ? Color(0xFF43A047) : Colors.grey,
                onPressed: () => onTabSelected(2),
                tooltip: 'Gráficos',
              ),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              color: currentIndex == 3 ? Color(0xFF43A047) : Colors.grey,
              onPressed: () => onTabSelected(3),
              tooltip: 'Contas',
            ),
            
          ],
        ),
      ),
    );
  }
} 