import 'package:flutter/material.dart';
import '../models/account.dart';
import '../database_helper.dart';

class AccountProvider with ChangeNotifier {
  final List<Account> _accounts = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Account> get accounts => List.unmodifiable(_accounts);

  AccountProvider() {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final dbAccounts = await DatabaseHelper().getAccounts();
    _accounts.clear();
    _accounts.addAll(dbAccounts);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAccount(String name, String type, double initialBalance) async {
    final account = Account(
      id: 0, // id será gerado pelo banco
      name: name,
      type: type,
      initialBalance: initialBalance,
    );
    final id = await DatabaseHelper().insertAccount(account);
    _accounts.add(Account(
      id: id,
      name: name,
      type: type,
      initialBalance: initialBalance,
    ));
    notifyListeners();
  }

  Future<void> toggleAccountActive(int id) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = Account(
        id: _accounts[index].id,
        name: _accounts[index].name,
        type: _accounts[index].type,
        initialBalance: _accounts[index].initialBalance,
        active: !_accounts[index].active,
      );
      await DatabaseHelper().updateAccount(updated);
      _accounts[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(int id) async {
    await DatabaseHelper().deleteAccount(id);
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> editAccount(int id, String name, String type, double initialBalance) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = Account(
        id: id,
        name: name,
        type: type,
        initialBalance: initialBalance,
        active: _accounts[index].active,
      );
      await DatabaseHelper().updateAccount(updated);
      _accounts[index] = updated;
      notifyListeners();
    }
  }
} 