import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/account_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/all_transactions_screen.dart';

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
        home: const AllTransactionsScreen(),
      ),
    );
  }
}
