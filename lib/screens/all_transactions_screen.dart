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
    final isLoading = transactionProvider.isLoading;

    // Calcular total de gastos (saídas) por categoria
    final Map<String, double> gastosPorCategoria = {};
    for (var t in transactions) {
      if (t.type == 'saida') {
        gastosPorCategoria[t.category] =
            (gastosPorCategoria[t.category] ?? 0) + t.amount;
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

    // Calcular saldo atual (apenas contas ativas)
    double saldoAtual = 0.0;
    final contasAtivas = accounts.where((a) => a.active).toList();
    for (var acc in contasAtivas) {
      double saldo = acc.initialBalance;
      for (var t in transactions.where((t) => t.accountId == acc.id)) {
        if (t.type == 'entrada') {
          saldo += t.amount;
        } else {
          saldo -= t.amount;
        }
      }
      saldoAtual += saldo;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF43A047)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lançamentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllTransactionsFullScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const AccountsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : accounts.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhum lançamento cadastrado.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cadastre uma conta e adicione seus primeiros lançamentos para começar a usar o app!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text('Cadastrar Conta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      if (accounts.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Despesa',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TransactionEditScreen(
                                          transaction: null,
                                          account: null,
                                          initialType: 'saida',
                                          onFinish: (message, success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(message),
                                                backgroundColor:
                                                    success
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                              ),
                              label: const Text(
                                'Receita',
                                style: TextStyle(color: Colors.green),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TransactionEditScreen(
                                          transaction: null,
                                          account: null,
                                          initialType: 'entrada',
                                          onFinish: (message, success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(message),
                                                backgroundColor:
                                                    success
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (accounts.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saldo Geral',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF388E3C),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_balance_wallet,
                                          color: Color(0xFF43A047),
                                          size: 28,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'R\$ ${saldoAtual.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF43A047),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (accounts.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saldo por Conta',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF388E3C),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...contasAtivas.map((acc) {
                                      double saldo = acc.initialBalance;
                                      for (var t in transactions.where(
                                        (t) => t.accountId == acc.id,
                                      )) {
                                        if (t.type == 'entrada') {
                                          saldo += t.amount;
                                        } else {
                                          saldo -= t.amount;
                                        }
                                      }
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.account_balance,
                                          color: Color(0xFF43A047),
                                        ),
                                        title: Text(
                                          acc.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: Text(
                                          'R\$ ${saldo.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color:
                                                saldo >= 0
                                                    ? Color(0xFF43A047)
                                                    : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gastos por Categoria',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 180,
                                    child:
                                        totalGastos > 0
                                            ? PieChart(
                                              PieChartData(
                                                sections: [
                                                  for (
                                                    int i = 0;
                                                    i < categorias.length;
                                                    i++
                                                  )
                                                    PieChartSectionData(
                                                      color:
                                                          chartColors[i %
                                                              chartColors
                                                                  .length],
                                                      value:
                                                          gastosPorCategoria[categorias[i]],
                                                      title: categorias[i],
                                                      radius: 60,
                                                      titleStyle:
                                                          const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                ],
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 40,
                                              ),
                                            )
                                            : Center(
                                              child: Text(
                                                'Nenhum gasto cadastrado ainda.',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                  ),
                                  if (totalGastos > 0)
                                    const SizedBox(height: 12),
                                  if (totalGastos > 0)
                                    Wrap(
                                      spacing: 12,
                                      children: [
                                        for (
                                          int i = 0;
                                          i < categorias.length;
                                          i++
                                        )
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color:
                                                      chartColors[i %
                                                          chartColors.length],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                categorias[i],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Card(
                            elevation: 6,
                            color: Colors.white,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 8.0,
                                      left: 4.0,
                                      bottom: 8.0,
                                    ),
                                    child: Text(
                                      'Últimos lançamentos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                  SizedBox(
                                    height: 320,
                                    child:
                                        ultimos10.isEmpty
                                            ? Center(
                                              child: Text(
                                                'Nenhum lançamento recente.',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                            : ListView.builder(
                                              itemCount: ultimos10.length,
                                              itemBuilder: (context, index) {
                                                final t = ultimos10[index];
                                                final account = accountProvider
                                                    .accounts
                                                    .firstWhere(
                                                      (a) =>
                                                          a.id == t.accountId,
                                                    );
                                                final isEntrada =
                                                    t.type == 'entrada';
                                                return ListTile(
                                                  leading: Icon(
                                                    isEntrada
                                                        ? Icons.arrow_downward
                                                        : Icons.arrow_upward,
                                                    color:
                                                        isEntrada
                                                            ? Colors.green
                                                            : Colors.red,
                                                  ),
                                                  title: Text(
                                                    t.description,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    '${t.category} | ${isEntrada ? 'Entrada' : 'Saída'} - ${t.date.day}/${t.date.month}/${t.date.year}\nConta: ${account.name}',
                                                  ),
                                                  trailing: Text(
                                                    (isEntrada ? '+ ' : '- ') +
                                                        'R\$ ${t.amount.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color:
                                                          isEntrada
                                                              ? Colors.green
                                                              : Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => TransactionEditScreen(
                                                              transaction: t,
                                                              onFinish: (
                                                                message,
                                                                success,
                                                              ) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      message,
                                                                    ),
                                                                    backgroundColor:
                                                                        success
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Center(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const AllTransactionsFullScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.list_alt,
                                          color: Color(0xFF1976D2),
                                        ),
                                        label: const Text(
                                          'Ver todos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1976D2),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF1976D2),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF1976D2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      floatingActionButton:
          (accounts.isNotEmpty)
              ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'add_receita',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TransactionEditScreen(
                                transaction: null,
                                account: null,
                                initialType: 'entrada',
                                onFinish: (message, success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor:
                                          success ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'add_despesa',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TransactionEditScreen(
                                transaction: null,
                                account: null,
                                initialType: 'saida',
                                onFinish: (message, success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor:
                                          success ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                  ),
                ],
              )
              : null,
    );
  }
}
