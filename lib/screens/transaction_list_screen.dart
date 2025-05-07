import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'transaction_edit_screen.dart';

class TransactionListScreen extends StatelessWidget {
  final Account account;
  const TransactionListScreen({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.getTransactionsByAccount(account.id);

    return Scaffold(
      appBar: AppBar(title: Text('Lançamentos - ${account.name}')),
      body: transactions.isEmpty
          ? const Center(child: Text('Nenhum lançamento para esta conta.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return ListTile(
                  title: Text(t.description),
                  subtitle: Text('${t.type} - ${t.date.day}/${t.date.month}/${t.date.year}'),
                  trailing: Text('R\$ ${t.amount.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionEditScreen(transaction: t),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionEditScreen(account: account),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Novo Lançamento',
      ),
    );
  }
} 