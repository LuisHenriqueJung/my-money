import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({Key? key}) : super(key: key);

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Conta Corrente';
  double _initialBalance = 0.0;

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
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
                onSaved: (value) => _name = value!,
              ),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<AccountProvider>(context, listen: false)
                        .addAccount(_name, _type, _initialBalance);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 