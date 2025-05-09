import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../models/transaction.dart';
import 'transaction_edit_screen.dart';

class AllTransactionsFullScreen extends StatefulWidget {
  const AllTransactionsFullScreen({Key? key}) : super(key: key);

  @override
  State<AllTransactionsFullScreen> createState() => _AllTransactionsFullScreenState();
}

class _AllTransactionsFullScreenState extends State<AllTransactionsFullScreen> {
  int? _selectedAccountId;
  String _orderBy = 'date_desc';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = accountProvider.accounts;
    List<Transaction> filtered = List.of(transactionProvider.transactions);

    // Filtro por conta
    if (_selectedAccountId != null) {
      filtered = filtered.where((t) => t.accountId == _selectedAccountId).toList();
    }

    // Ordenação
    if (_orderBy == 'date_desc') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (_orderBy == 'date_asc') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else if (_orderBy == 'category') {
      filtered.sort((a, b) => a.category.compareTo(b.category));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Lançamentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedAccountId,
                    isExpanded: true,
                    hint: const Text('Filtrar por conta'),
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text('Todas as contas')),
                      ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                    ],
                    onChanged: (value) => setState(() => _selectedAccountId = value),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) => setState(() => _orderBy = value),
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'date_desc',
                      checked: _orderBy == 'date_desc',
                      child: const Text('Data (mais recentes)'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'date_asc',
                      checked: _orderBy == 'date_asc',
                      child: const Text('Data (mais antigos)'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'category',
                      checked: _orderBy == 'category',
                      child: const Text('Categoria'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_rounded,
                          size: 54,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        const Text(
                          'Nenhum lançamento encontrado.',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionEditScreen(initialType: 'entrada'),
                              ),
                            );
                          },
                          child: Container(
                            width: 220,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Color(0xFF43A047), width: 2),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  child: Icon(Icons.arrow_downward, size: 44, color: Colors.green.withOpacity(0.10)),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.arrow_downward, color: Color(0xFF43A047), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Cadastrar Receita', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF43A047))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionEditScreen(initialType: 'saida'),
                              ),
                            );
                          },
                          child: Container(
                            width: 220,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Color(0xFFD32F2F), width: 2),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  child: Icon(Icons.arrow_upward, size: 44, color: Colors.red.withOpacity(0.10)),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.arrow_upward, color: Color(0xFFD32F2F), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Cadastrar Despesa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      final account = accounts.firstWhere((a) => a.id == t.accountId);
                      return Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white, size: 32),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Excluir lançamento'),
                              content: const Text('Tem certeza que deseja excluir este lançamento?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          Provider.of<TransactionProvider>(context, listen: false).removeTransaction(t.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: t.type == 'saida' ? Colors.red[200] : Colors.green[200],
                              child: Icon(
                                t.type == 'saida' ? Icons.arrow_downward : Icons.arrow_upward,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              t.description,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${t.category} | ${t.type}'),
                                Text('Conta: ${account.name}'),
                                Text('Data: ${t.date.day}/${t.date.month}/${t.date.year}'),
                              ],
                            ),
                            trailing: Text(
                              'R\$ ${t.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: t.type == 'saida' ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionEditScreen(transaction: t),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: filtered.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_receita',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionEditScreen(initialType: 'entrada'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  label: const Text('Receita'),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'fab_despesa',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionEditScreen(initialType: 'saida'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  label: const Text('Despesa'),
                  backgroundColor: Colors.red,
                ),
              ],
            )
          : null,
    );
  }
} 