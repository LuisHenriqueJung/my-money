import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountProvider with ChangeNotifier {
  final List<Account> _accounts = [];
  int _nextId = 1;

  List<Account> get accounts => List.unmodifiable(_accounts);

  AccountProvider() {
    // Contas mocadas
    addAccount('Conta Corrente', 'Conta Corrente', 1000.0);
    addAccount('Poupança', 'Poupança', 500.0);
    addAccount('Carteira', 'Carteira', 150.0);
  }

  void addAccount(String name, String type, double initialBalance) {
    final account = Account(
      id: _nextId++,
      name: name,
      type: type,
      initialBalance: initialBalance,
    );
    _accounts.add(account);
    notifyListeners();
  }

  void toggleAccountActive(int id) {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _accounts[index] = Account(
        id: _accounts[index].id,
        name: _accounts[index].name,
        type: _accounts[index].type,
        initialBalance: _accounts[index].initialBalance,
        active: !_accounts[index].active,
      );
      notifyListeners();
    }
  }
} 