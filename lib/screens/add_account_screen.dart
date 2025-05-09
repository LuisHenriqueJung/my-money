import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';

class AddAccountScreen extends StatefulWidget {
  final void Function(String message, bool success)? onFinish;
  final Account? account;
  const AddAccountScreen({Key? key, this.onFinish, this.account}) : super(key: key);

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Conta Corrente';
  double _initialBalance = 0.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _name = widget.account!.name;
      _type = widget.account!.type;
      _initialBalance = widget.account!.initialBalance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.account != null ? 'Editar Conta' : 'Adicionar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nome da Conta'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
                onSaved: (value) => _name = value != null && value.isNotEmpty
                    ? value[0].toUpperCase() + value.substring(1)
                    : '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Conta Corrente', child: Text('Conta Corrente')),
                  DropdownMenuItem(value: 'Poupança', child: Text('Poupança')),
                  DropdownMenuItem(value: 'Carteira', child: Text('Carteira')),
                ],
                onChanged: (value) => setState(() => _type = value!),
                decoration: const InputDecoration(labelText: 'Tipo de Conta'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _initialBalance != 0.0 ? _initialBalance.toString() : '',
                decoration: const InputDecoration(labelText: 'Saldo Inicial'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o saldo';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
                onSaved: (value) => _initialBalance = double.parse(value!),
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
                            if (widget.account != null) {
                              await Provider.of<AccountProvider>(context, listen: false)
                                  .editAccount(widget.account!.id, _name, _type, _initialBalance);
                            } else {
                              await Provider.of<AccountProvider>(context, listen: false)
                                  .addAccount(_name, _type, _initialBalance);
                            }
                            if (mounted) {
                              widget.onFinish?.call('Conta salva com sucesso!', true);
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              widget.onFinish?.call('Erro ao salvar conta: $e', false);
                            }
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        }
                      },
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 