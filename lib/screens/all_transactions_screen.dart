import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import 'transaction_edit_screen.dart';
import 'all_transactions_full_screen.dart';
import 'accounts_screen.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final transactions = transactionProvider.transactions;
    final accounts = accountProvider.accounts;

    // Calcular total de gastos (saídas) por categoria
    final Map<String, double> gastosPorCategoria = {};
    for (var t in transactions) {
      if (t.type == 'saida') {
        gastosPorCategoria[t.category] = (gastosPorCategoria[t.category] ?? 0) + t.amount;
      }
    }
    final totalGastos = gastosPorCategoria.values.fold(0.0, (a, b) => a + b);
    final List<String> categorias = gastosPorCategoria.keys.toList();
    final List<Color> chartColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.red,
      Colors.amber,
    ];

    // Ordenar lançamentos por data decrescente e pegar os 10 mais recentes
    final ultimosLancamentos = List.of(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final ultimos10 = ultimosLancamentos.take(10).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lançamentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AllTransactionsFullScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Contas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (totalGastos > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Gastos por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (int i = 0; i < categorias.length; i++)
                                PieChartSectionData(
                                  color: chartColors[i % chartColors.length],
                                  value: gastosPorCategoria[categorias[i]],
                                  title: categorias[i],
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: [
                          for (int i = 0; i < categorias.length; i++)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: chartColors[i % chartColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(categorias[i], style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Últimos lançamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ultimos10.isEmpty
                      ? const Center(child: Text('Nenhum lançamento cadastrado.'))
                      : ListView.builder(
                          itemCount: ultimos10.length,
                          itemBuilder: (context, index) {
                            final t = ultimos10[index];
                            final account = accountProvider.accounts.firstWhere((a) => a.id == t.accountId);
                            return ListTile(
                              title: Text('${t.description}'),
                              subtitle: Text('${t.category} | ${t.type} - ${t.date.day}/${t.date.month}/${t.date.year}\nConta: ${account.name}'),
                              trailing: Text('R\$ ${t.amount.toStringAsFixed(2)}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionEditScreen(transaction: t),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllTransactionsFullScreen(),
                          ),
                        );
                      },
                      child: const Text('Ver todos'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Novo Lançamento',
      ),
    );
  }
} 