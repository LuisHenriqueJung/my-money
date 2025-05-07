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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const AllTransactionsScreen(),
      ),
    );
  }
}
