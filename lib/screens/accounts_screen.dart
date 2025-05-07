import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import 'add_account_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _includeInactive = false;
  bool _inactiveAffectBalance = false;

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Conta Corrente';
  double _initialBalance = 0.0;

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = _includeInactive
        ? accountProvider.accounts
        : accountProvider.accounts.where((a) => a.active).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Contas')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Exibir contas inativas'),
            value: _includeInactive,
            onChanged: (v) => setState(() => _includeInactive = v),
          ),
          SwitchListTile(
            title: const Text('Contas inativas afetam saldo total'),
            value: _inactiveAffectBalance,
            onChanged: (v) => setState(() => _inactiveAffectBalance = v),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final a = accounts[index];
                return ListTile(
                  leading: Icon(a.active ? Icons.account_balance_wallet : Icons.remove_circle, color: a.active ? Colors.green : Colors.red),
                  title: Text(a.name),
                  subtitle: Text('${a.type} | Saldo inicial: R\$ ${a.initialBalance.toStringAsFixed(2)}'),
                  trailing: Switch(
                    value: a.active,
                    onChanged: (_) {
                      accountProvider.toggleAccountActive(a.id);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Conta'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAccountScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 