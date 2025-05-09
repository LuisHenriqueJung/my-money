import 'package:flutter/material.dart';
import 'package:my_money_gestao_financeira/screens/all_transactions_screen.dart';
import 'package:provider/provider.dart';
import 'providers/account_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/all_transactions_full_screen.dart';
import 'screens/accounts_screen.dart';
import 'widgets/main_bottom_app_bar.dart';
import 'screens/transaction_edit_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Gestão Financeira',
        theme: ThemeData(
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF43A047), // verde folha moderno
            onPrimary: Colors.white,
            secondary: Color(0xFFB2DFDB), // verde água/mint
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.white,
            background: Color(0xFFF6FFF6),
            onBackground: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF43A047),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF43A047),
            foregroundColor: Colors.white,
            shape: StadiumBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43A047))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43A047))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43A047), width: 2)),
            labelStyle: const TextStyle(color: Color(0xFF43A047)),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            shadowColor: Colors.black12,
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all(const Color(0xFF43A047)),
            trackColor: MaterialStateProperty.all(const Color(0xFFB2DFDB)),
          ),
          drawerTheme: const DrawerThemeData(
            backgroundColor: Color(0xFFF6FFF6),
          ),
          scaffoldBackgroundColor: const Color(0xFFF6FFF6),
          fontFamily: 'Roboto',
        ),
        home: const MainNavigationScreen(),
        routes: {
          '/add-receita': (context) => TransactionEditScreen(initialType: 'entrada'),
          '/add-despesa': (context) => TransactionEditScreen(initialType: 'saida'),
        },
      ),
    );
  }
}

// NOVO WIDGET DE NAVEGAÇÃO PRINCIPAL
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFabOpen = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const AllTransactionsScreen(),
      const AllTransactionsFullScreen(),
      const AccountsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          // FABs expansíveis
          if (_isFabOpen)
            Positioned(
              bottom: 50,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'fab_receita',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Receita'),
                        onPressed: () {
                          _toggleFab();
                          Navigator.pushNamed(context, '/add-receita');
                        },
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton.extended(
                        heroTag: 'fab_despesa',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Despesa'),
                        onPressed: () {
                          _toggleFab();
                          Navigator.pushNamed(context, '/add-despesa');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: MainBottomAppBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
            _isFabOpen = false;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _fabController.value * 0.75 * 3.1416, // ~135 graus
            child: FloatingActionButton(
              heroTag: 'fab_main',
              backgroundColor: _isFabOpen ? Colors.white : const Color(0xFF43A047),
              foregroundColor: _isFabOpen ? const Color(0xFF43A047) : Colors.white,
              onPressed: _toggleFab,
              child: _isFabOpen
                  ? const Icon(Icons.close, color: Color(0xFF43A047), size: 28)
                  : const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        },
      ),
    );
  }
}
