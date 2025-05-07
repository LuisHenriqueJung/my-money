import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';

class TransactionEditScreen extends StatefulWidget {
  final Transaction? transaction;
  final Account? account;
  const TransactionEditScreen({Key? key, this.transaction, this.account}) : super(key: key);

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late String _description;
  late DateTime _date;
  String _type = 'entrada';
  String _category = 'Outros';
  late int? _accountId;

  List<String> get _entradaCategorias => ['Salário', 'Investimentos', 'Outros'];
  List<String> get _saidaCategorias => ['Alimentação', 'Transporte', 'Saúde', 'Lazer', 'Outros'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amount = widget.transaction!.amount;
      _description = widget.transaction!.description;
      _date = widget.transaction!.date;
      _type = widget.transaction!.type;
      _accountId = widget.transaction!.accountId;
      _category = widget.transaction!.category;
    } else if (widget.account != null) {
      _amount = 0.0;
      _description = '';
      _date = DateTime.now();
      _type = 'entrada';
      _accountId = widget.account!.id;
      _category = 'Outros';
    } else {
      _amount = 0.0;
      _description = '';
      _date = DateTime.now();
      _type = 'entrada';
      _accountId = null;
      _category = 'Outros';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = Provider.of<AccountProvider>(context).accounts;
    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction != null ? 'Editar Lançamento' : 'Novo Lançamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.isEmpty ? 'Informe a descrição' : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _amount != 0.0 ? _amount.toString() : '',
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                  DropdownMenuItem(value: 'saida', child: Text('Saída')),
                ],
                onChanged: (value) => setState(() {
                  _type = value!;
                  _category = (_type == 'entrada' ? _entradaCategorias : _saidaCategorias).first;
                }),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              DropdownButtonFormField<int>(
                value: _accountId,
                items: accounts.map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Text(a.name),
                )).toList(),
                onChanged: (value) => setState(() => _accountId = value),
                decoration: const InputDecoration(labelText: 'Conta'),
                validator: (value) => value == null ? 'Selecione a conta' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: (_type == 'entrada' ? _entradaCategorias : _saidaCategorias)
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              ListTile(
                title: Text('Data: ${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final provider = Provider.of<TransactionProvider>(context, listen: false);
                    if (widget.transaction != null) {
                      provider.editTransaction(
                        widget.transaction!.id,
                        _amount,
                        _description,
                        _date,
                        _type,
                        _category,
                      );
                    } else if (_accountId != null) {
                      provider.addTransaction(
                        _accountId!,
                        _amount,
                        _description,
                        _date,
                        _type,
                        _category,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.transaction != null ? 'Salvar Alterações' : 'Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 