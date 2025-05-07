import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import 'add_account_screen.dart';
import 'account_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = accountProvider.accounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Contas'),
      ),
      body: accounts.isEmpty
          ? const Center(child: Text('Nenhuma conta cadastrada.'))
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  title: Text(account.name),
                  subtitle: Text('Tipo: ${account.type}'),
                  trailing: Text('R\$ ${account.initialBalance.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailScreen(account: account),
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
            MaterialPageRoute(builder: (context) => const AddAccountScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Conta',
      ),
    );
  }
} 