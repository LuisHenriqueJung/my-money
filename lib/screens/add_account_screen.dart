import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';

class AddAccountScreen extends StatefulWidget {
  final void Function(String message, bool success)? onFinish;
  const AddAccountScreen({Key? key, this.onFinish}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
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
                            await Provider.of<AccountProvider>(context, listen: false)
                                .addAccount(_name, _type, _initialBalance);
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