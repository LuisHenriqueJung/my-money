import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _prefsLoaded = false;

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Conta Corrente';
  double _initialBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _includeInactive = prefs.getBool('includeInactive') ?? false;
        _inactiveAffectBalance = prefs.getBool('inactiveAffectBalance') ?? false;
        _prefsLoaded = true;
      });
      print('Prefs loaded: includeInactive=$_includeInactive, inactiveAffectBalance=$_inactiveAffectBalance');
    } catch (e) {
      setState(() {
        _prefsLoaded = true;
      });
      print('Erro ao carregar prefs: $e');
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('includeInactive', _includeInactive);
    await prefs.setBool('inactiveAffectBalance', _inactiveAffectBalance);
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = _includeInactive
        ? accountProvider.accounts
        : accountProvider.accounts.where((a) => a.active).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Contas')),
      body: !_prefsLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SwitchListTile(
            title: const Text('Exibir contas inativas'),
            value: _includeInactive,
            onChanged: (v) async {
              setState(() => _includeInactive = v);
              await _savePrefs();
            },
          ),
          SwitchListTile(
            title: const Text('Contas inativas afetam saldo total'),
            value: _inactiveAffectBalance,
            onChanged: (v) async {
              setState(() => _inactiveAffectBalance = v);
              await _savePrefs();
            },
          ),
          Expanded(
            child: accounts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 24),
                          Text(
                            _includeInactive
                              ? 'Nenhuma conta cadastrada.'
                              : 'Nenhuma conta ativa no momento.',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _includeInactive
                              ? 'Adicione uma conta para começar a usar o app.'
                              : 'Ative ou cadastre uma nova conta para começar a usar o app.',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final a = accounts[index];
                return ListTile(
                  leading: Icon(a.active ? Icons.account_balance_wallet : Icons.remove_circle, color: a.active ? Colors.green : Colors.red),
                  title: Text(
                    a.name,
                    style: TextStyle(
                      color: a.active ? Colors.black : Colors.grey,
                      decoration: a.active ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    a.active
                        ? '${a.type} | Saldo inicial: R\$ ${a.initialBalance.toStringAsFixed(2)}'
                        : 'Desabilitada • ${a.type} | Saldo inicial: R\$ ${a.initialBalance.toStringAsFixed(2)}',
                    style: TextStyle(color: a.active ? Colors.black54 : Colors.redAccent, fontStyle: a.active ? null : FontStyle.italic),
                  ),
                  trailing: Switch(
                    value: a.active,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.shade100,
                    onChanged: (_) {
                      accountProvider.toggleAccountActive(a.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAccountScreen(account: a),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: OutlinedButton.icon(
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