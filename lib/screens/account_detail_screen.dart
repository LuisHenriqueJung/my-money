import 'package:flutter/material.dart';
import '../models/account.dart';
import 'transaction_list_screen.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';

class AccountDetailScreen extends StatelessWidget {
  final Account account;
  const AccountDetailScreen({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.getTransactionsByAccount(account.id);
    double saldoAtual = account.initialBalance;
    for (var t in transactions) {
      if (t.type == 'entrada') {
        saldoAtual += t.amount;
      } else {
        saldoAtual -= t.amount;
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Conta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome:', style: Theme.of(context).textTheme.titleMedium),
            Text(account.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Tipo:', style: Theme.of(context).textTheme.titleMedium),
            Text(account.type, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Saldo Inicial:', style: Theme.of(context).textTheme.titleMedium),
            Text('R\$ ${account.initialBalance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Saldo Atual:', style: Theme.of(context).textTheme.titleMedium),
            Text('R\$ ${saldoAtual.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('Ver Lançamentos'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionListScreen(account: account),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<AccountProvider>(
                    builder: (context, provider, _) {
                      final acc = provider.accounts.firstWhere((a) => a.id == account.id, orElse: () => account);
                      return ElevatedButton.icon(
                        icon: Icon(acc.active ? Icons.block : Icons.check_circle),
                        label: Text(acc.active ? 'Desabilitar Conta' : 'Habilitar Conta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: acc.active ? Colors.red : Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                          await Provider.of<AccountProvider>(context, listen: false).toggleAccountActive(acc.id);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 