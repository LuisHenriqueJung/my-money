import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import 'package:money_input_formatter/money_input_formatter.dart';

class TransactionEditScreen extends StatefulWidget {
  final Transaction? transaction;
  final Account? account;
  final void Function(String message, bool success)? onFinish;
  final String? initialType;
  const TransactionEditScreen({Key? key, this.transaction, this.account, this.onFinish, this.initialType}) : super(key: key);

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
  bool _isSaving = false;
  late TextEditingController _amountController;

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
      _type = widget.initialType ?? 'entrada';
      _accountId = widget.account!.id;
      _category = 'Outros';
    } else {
      _amount = 0.0;
      _description = '';
      _date = DateTime.now();
      _type = widget.initialType ?? 'entrada';
      _accountId = null;
      _category = 'Outros';
    }
    _amountController = TextEditingController(
      text: _amount != 0.0 ? _amount.toStringAsFixed(2).replaceAll('.', ',') : ''
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = accountProvider.accounts;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Stack(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: widget.transaction != null
                    ? const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : (widget.initialType == 'saida'
                        ? const LinearGradient(
                            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            ),
            if (widget.transaction == null)
              Positioned(
                right: 24,
                top: 18,
                child: Icon(
                  widget.initialType == 'saida' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: widget.initialType == 'saida'
                      ? Colors.red.withOpacity(0.13)
                      : Colors.green.withOpacity(0.13),
                  size: 90,
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 42),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    if (widget.transaction == null) const SizedBox(width: 10),
                    Text(
                      widget.transaction != null
                          ? 'Editar Lançamento'
                          : (widget.initialType == 'saida' ? 'Nova Despesa' : 'Nova Receita'),
                      style: TextStyle(
                        color: widget.transaction != null
                            ? Colors.white
                            : (widget.initialType == 'saida' ? Colors.red : Colors.green),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botão de voltar
            Positioned(
              left: 8,
              top: 55,
              child: IconButton(
                icon:  Icon(Icons.arrow_back, color: (widget.initialType == 'saida' ? Colors.red : Colors.green), size: 28),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Voltar',
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _description,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe a descrição' : null,
                  onSaved: (value) => _description = value != null && value.isNotEmpty
                      ? value[0].toUpperCase() + value.substring(1)
                      : '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o valor';
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      // Replace comma with dot for parsing
                      final clean = value.replaceAll(',', '.');
                      _amount = double.tryParse(clean) ?? 0.0;
                    } else {
                      _amount = 0.0;
                    }
                  },
                ),
                const SizedBox(height: 16),
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
               
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: (_type == 'entrada' ? _entradaCategorias : _saidaCategorias)
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                 const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'entrada', child: Text('Receita')),
                    DropdownMenuItem(value: 'saida', child: Text('Despesa')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                      // Atualiza categoria para o primeiro da lista ao trocar tipo
                      _category = (_type == 'entrada' ? _entradaCategorias : _saidaCategorias).first;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                const SizedBox(height: 16),
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
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() => _isSaving = true);
                            try {
                              final provider = Provider.of<TransactionProvider>(context, listen: false);
                              if (widget.transaction != null) {
                                await provider.editTransaction(
                                  widget.transaction!.id,
                                  _amount,
                                  _description,
                                  _date,
                                  _type,
                                  _category,
                                );
                              } else if (_accountId != null) {
                                await provider.addTransaction(
                                  _accountId!,
                                  _amount,
                                  _description,
                                  _date,
                                  _type,
                                  _category,
                                );
                              }
                              if (mounted) {
                                widget.onFinish?.call(
                                  widget.transaction != null ? 'Lançamento atualizado com sucesso!' : 'Lançamento adicionado com sucesso!',
                                  true,
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (mounted) {
                                widget.onFinish?.call('Erro ao salvar lançamento: $e', false);
                              }
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.transaction != null ? 'Salvar Alterações' : 'Adicionar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 