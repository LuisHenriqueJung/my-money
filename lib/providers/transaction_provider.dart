import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> getTransactionsByAccount(int accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final dbTransactions = await DatabaseHelper().getTransactions();
    _transactions.clear();
    _transactions.addAll(dbTransactions);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(int accountId, double amount, String description, DateTime date, String type, String category) async {
    final transaction = Transaction(
      id: 0, // id será gerado pelo banco
      accountId: accountId,
      amount: amount,
      description: description,
      date: date,
      type: type,
      category: category,
    );
    final id = await DatabaseHelper().insertTransaction(transaction);
    _transactions.add(Transaction(
      id: id,
      accountId: accountId,
      amount: amount,
      description: description,
      date: date,
      type: type,
      category: category,
    ));
    notifyListeners();
  }

  Future<void> editTransaction(int id, double amount, String description, DateTime date, String type, String category) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _transactions[index];
      final updated = Transaction(
        id: old.id,
        accountId: old.accountId,
        amount: amount,
        description: description,
        date: date,
        type: type,
        category: category,
      );
      await DatabaseHelper().updateTransaction(updated);
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  Future<void> removeTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
} 