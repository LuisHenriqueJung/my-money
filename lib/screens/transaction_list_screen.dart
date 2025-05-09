import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'transaction_edit_screen.dart';

class TransactionListScreen extends StatelessWidget {
  final Account account;
  const TransactionListScreen({Key? key, required this.account})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.getTransactionsByAccount(
      account.id,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Lançamentos - ${account.name}')),
      body:
          transactions.isEmpty
              ? const Center(child: Text('Nenhum lançamento para esta conta.'))
              : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  return ListTile(
                    title: Text(t.description),
                    subtitle: Text(
                      '${t.type} - ${t.date.day}/${t.date.month}/${t.date.year}',
                    ),
                    trailing: Text('R\$ ${t.amount.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TransactionEditScreen(transaction: t),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_receita',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TransactionEditScreen(
                        account: account,
                        initialType: 'entrada',
                      ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_downward, color: Colors.white),
            label: const Text('Receita'),
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_despesa',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TransactionEditScreen(
                        account: account,
                        initialType: 'saida',
                      ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
            label: const Text('Despesa'),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
