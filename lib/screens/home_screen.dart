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
    final isLoading = accountProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Contas'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? const Center(child: Text('Nenhuma conta cadastrada.'))
              : ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return ListTile(
                      title: Text(
                        account.name,
                        style: TextStyle(
                          color: account.active ? Colors.black : Colors.grey,
                          decoration: account.active ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(account.active ? 'Tipo: ${account.type}' : 'Desabilitada • Tipo: ${account.type}',
                        style: TextStyle(color: account.active ? Colors.black54 : Colors.redAccent, fontStyle: account.active ? null : FontStyle.italic),
                      ),
                      trailing: Text('R\$ ${account.initialBalance.toStringAsFixed(2)}',
                        style: TextStyle(color: account.active ? Colors.black : Colors.grey),
                      ),
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
            MaterialPageRoute(
              builder: (context) => AddAccountScreenWithSnackBar(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Conta',
      ),
    );
  }
}

// Widget wrapper para AddAccountScreen com callback de SnackBar
class AddAccountScreenWithSnackBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddAccountScreenWithCallback(
      onFinish: (message, success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: success ? Colors.green : Colors.red),
        );
      },
    );
  }
}

// AddAccountScreen com callback
class AddAccountScreenWithCallback extends StatefulWidget {
  final void Function(String message, bool success)? onFinish;
  const AddAccountScreenWithCallback({Key? key, this.onFinish}) : super(key: key);

  @override
  State<AddAccountScreenWithCallback> createState() => _AddAccountScreenWithCallbackState();
}

class _AddAccountScreenWithCallbackState extends State<AddAccountScreenWithCallback> {
  @override
  Widget build(BuildContext context) {
    return AddAccountScreen(onFinish: widget.onFinish);
  }
} 