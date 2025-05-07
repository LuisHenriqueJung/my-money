import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  int _nextId = 1;

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> getTransactionsByAccount(int accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  void addTransaction(int accountId, double amount, String description, DateTime date, String type, String category) {
    final transaction = Transaction(
      id: _nextId++,
      accountId: accountId,
      amount: amount,
      description: description,
      date: date,
      type: type,
      category: category,
    );
    _transactions.add(transaction);
    notifyListeners();
  }

  void editTransaction(int id, double amount, String description, DateTime date, String type, String category) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _transactions[index];
      _transactions[index] = Transaction(
        id: old.id,
        accountId: old.accountId,
        amount: amount,
        description: description,
        date: date,
        type: type,
        category: category,
      );
      notifyListeners();
    }
  }

  void removeTransaction(int id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  TransactionProvider() {
    // Lançamentos mocados
    addTransaction(1, 200.0, 'Salário', DateTime.now().subtract(const Duration(days: 5)), 'entrada', 'Outros');
    addTransaction(1, 50.0, 'Supermercado', DateTime.now().subtract(const Duration(days: 3)), 'saida', 'Alimentação');
    addTransaction(2, 30.0, 'Rendimento', DateTime.now().subtract(const Duration(days: 2)), 'entrada', 'Outros');
    addTransaction(3, 20.0, 'Lanche', DateTime.now().subtract(const Duration(days: 1)), 'saida', 'Alimentação');
    addTransaction(1, 15.0, 'Uber', DateTime.now().subtract(const Duration(days: 1)), 'saida', 'Transporte');
    addTransaction(1, 100.0, 'Farmácia', DateTime.now().subtract(const Duration(days: 4)), 'saida', 'Saúde');
  }
} 