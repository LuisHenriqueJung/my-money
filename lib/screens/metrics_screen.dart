import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';

enum PeriodoFiltro {
  esteMes,
  ultimos3Meses,
  ultimos6Meses,
  esteAno,
  personalizado,
}

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({Key? key}) : super(key: key);

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  PeriodoFiltro _periodoSelecionado = PeriodoFiltro.esteMes;
  DateTimeRange? _rangePersonalizado;

  DateTime get _inicioPeriodo {
    final now = DateTime.now();
    switch (_periodoSelecionado) {
      case PeriodoFiltro.esteMes:
        return DateTime(now.year, now.month, 1);
      case PeriodoFiltro.ultimos3Meses:
        return DateTime(now.year, now.month - 2, 1);
      case PeriodoFiltro.ultimos6Meses:
        return DateTime(now.year, now.month - 5, 1);
      case PeriodoFiltro.esteAno:
        return DateTime(now.year, 1, 1);
      case PeriodoFiltro.personalizado:
        return _rangePersonalizado?.start ?? DateTime(now.year, now.month, 1);
    }
  }

  DateTime get _fimPeriodo {
    final now = DateTime.now();
    switch (_periodoSelecionado) {
      case PeriodoFiltro.esteMes:
      case PeriodoFiltro.ultimos3Meses:
      case PeriodoFiltro.ultimos6Meses:
      case PeriodoFiltro.esteAno:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case PeriodoFiltro.personalizado:
        return _rangePersonalizado?.end ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer2<TransactionProvider, AccountProvider>(
        builder: (context, transactionProvider, accountProvider, _) {
          final allTransactions = transactionProvider.transactions;
          final accounts = accountProvider.accounts;

          // Filtrar transações pelo período selecionado
          final transactions = allTransactions.where((t) {
            return t.date.isAfter(_inicioPeriodo.subtract(const Duration(days: 1))) &&
                   t.date.isBefore(_fimPeriodo.add(const Duration(days: 1)));
          }).toList();

          // Pie chart: Gastos por categoria
          final Map<String, double> gastosPorCategoria = {};
          for (var t in transactions) {
            if (t.type == 'saida') {
              gastosPorCategoria[t.category] =
                  (gastosPorCategoria[t.category] ?? 0) + t.amount;
            }
          }
          final totalGastos = gastosPorCategoria.values.fold(
            0.0,
            (a, b) => a + b,
          );

          // Bar chart: Receitas e Despesas por mês
          final Map<String, double> receitasPorMes = {};
          final Map<String, double> despesasPorMes = {};
          for (var t in transactions) {
            final mes =
                '${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
            if (t.type == 'entrada') {
              receitasPorMes[mes] = (receitasPorMes[mes] ?? 0) + t.amount;
            } else {
              despesasPorMes[mes] = (despesasPorMes[mes] ?? 0) + t.amount;
            }
          }
          final meses =
              <String>{...receitasPorMes.keys, ...despesasPorMes.keys}.toList()
                ..sort((a, b) {
                  final ay = int.parse(a.split('/')[1]);
                  final am = int.parse(a.split('/')[0]);
                  final by = int.parse(b.split('/')[1]);
                  final bm = int.parse(b.split('/')[0]);
                  return ay != by ? ay.compareTo(by) : am.compareTo(bm);
                });

          // 1. LineChart: Linha do tempo do saldo
          final saldoPorData = <DateTime, double>{};
          double saldo = 0.0;
          final sorted = List.of(transactions)
            ..sort((a, b) => a.date.compareTo(b.date));
          for (var t in sorted) {
            if (t.type == 'entrada') {
              saldo += t.amount;
            } else {
              saldo -= t.amount;
            }
            saldoPorData[t.date] = saldo;
          }

          // 2. Stacked BarChart: Receitas e despesas empilhadas por mês
          // (usaremos o mesmo dados de receitasPorMes e despesasPorMes)

          // 3. AreaChart: Receitas e despesas acumuladas ao longo do tempo
          final receitasAcumuladas = <DateTime, double>{};
          final despesasAcumuladas = <DateTime, double>{};
          double receitaAcum = 0.0;
          double despesaAcum = 0.0;
          for (var t in sorted) {
            if (t.type == 'entrada') {
              receitaAcum += t.amount;
            } else {
              despesaAcum += t.amount;
            }
            receitasAcumuladas[t.date] = receitaAcum;
            despesasAcumuladas[t.date] = despesaAcum;
          }

          // 4. RadarChart: Gastos por categoria nos últimos 3 meses
          final now = DateTime.now();
          final ultimos3Meses =
              List.generate(3, (i) {
                final d = DateTime(now.year, now.month - i, 1);
                return '${d.month.toString().padLeft(2, '0')}/${d.year}';
              }).reversed.toList();
          final categoriasRadar = gastosPorCategoria.keys.toList();
          final radarData = <String, List<double>>{};
          for (var cat in categoriasRadar) {
            radarData[cat] = [];
            for (var mes in ultimos3Meses) {
              final valor = transactions
                  .where(
                    (t) =>
                        t.type == 'saida' &&
                        t.category == cat &&
                        '${t.date.month.toString().padLeft(2, '0')}/${t.date.year}' ==
                            mes,
                  )
                  .fold<double>(0, (a, b) => a + b.amount);
              radarData[cat]!.add(valor);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Filtro de período
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Text('Período:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      DropdownButton<PeriodoFiltro>(
                        value: _periodoSelecionado,
                        items: const [
                          DropdownMenuItem(
                            value: PeriodoFiltro.esteMes,
                            child: Text('Este mês'),
                          ),
                          DropdownMenuItem(
                            value: PeriodoFiltro.ultimos3Meses,
                            child: Text('Últimos 3 meses'),
                          ),
                          DropdownMenuItem(
                            value: PeriodoFiltro.ultimos6Meses,
                            child: Text('Últimos 6 meses'),
                          ),
                          DropdownMenuItem(
                            value: PeriodoFiltro.esteAno,
                            child: Text('Este ano'),
                          ),
                          DropdownMenuItem(
                            value: PeriodoFiltro.personalizado,
                            child: Text('Personalizado'),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == PeriodoFiltro.personalizado) {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(now.year - 5),
                              lastDate: DateTime(now.year + 1, 12, 31),
                              initialDateRange: _rangePersonalizado ?? DateTimeRange(
                                start: DateTime(now.year, now.month, 1),
                                end: now,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _periodoSelecionado = value!;
                                _rangePersonalizado = picked;
                              });
                            }
                          } else {
                            setState(() {
                              _periodoSelecionado = value!;
                            });
                          }
                        },
                      ),
                      if (_periodoSelecionado == PeriodoFiltro.personalizado && _rangePersonalizado != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '${_rangePersonalizado!.start.day.toString().padLeft(2, '0')}/'
                            '${_rangePersonalizado!.start.month.toString().padLeft(2, '0')}/'
                            '${_rangePersonalizado!.start.year} - '
                            '${_rangePersonalizado!.end.day.toString().padLeft(2, '0')}/'
                            '${_rangePersonalizado!.end.month.toString().padLeft(2, '0')}/'
                            '${_rangePersonalizado!.end.year}',
                            style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PieChartWidget(
                    gastosPorCategoria: gastosPorCategoria,
                    totalGastos: totalGastos,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BarChartWidget(
                    meses: meses,
                    receitasPorMes: receitasPorMes,
                    despesasPorMes: despesasPorMes,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChartWidget(saldoPorData: saldoPorData),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AreaChartWidget(
                    receitasAcumuladas: receitasAcumuladas,
                    despesasAcumuladas: despesasAcumuladas,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RadarChartWidget(
                    categorias: categoriasRadar,
                    meses: ultimos3Meses,
                    radarData: radarData,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final Map<String, double> gastosPorCategoria;
  final double totalGastos;
  const PieChartWidget({
    super.key,
    required this.gastosPorCategoria,
    required this.totalGastos,
  });

  @override
  Widget build(BuildContext context) {
    final categorias = gastosPorCategoria.keys.toList();
    final chartColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.red,
      Colors.amber,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gastos por Categoria',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child:
              totalGastos > 0
                  ? PieChart(
                    PieChartData(
                      sections: [
                        for (int i = 0; i < categorias.length; i++)
                          PieChartSectionData(
                            color: chartColors[i % chartColors.length],
                            value: gastosPorCategoria[categorias[i]],
                            title: categorias[i],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  )
                  : const Center(child: Text('Nenhum gasto cadastrado ainda.')),
        ),
        if (totalGastos > 0) const SizedBox(height: 12),
        if (totalGastos > 0)
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
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<String> meses;
  final Map<String, double> receitasPorMes;
  final Map<String, double> despesasPorMes;
  const BarChartWidget({
    super.key,
    required this.meses,
    required this.receitasPorMes,
    required this.despesasPorMes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receitas e Despesas por Mês',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  [
                    ...receitasPorMes.values,
                    ...despesasPorMes.values,
                  ].fold<double>(0, (prev, el) => el > prev ? el : prev) *
                  1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= meses.length)
                        return const SizedBox.shrink();
                      return Text(
                        meses[idx],
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (int i = 0; i < meses.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: receitasPorMes[meses[i]] ?? 0,
                        color: Colors.green,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: despesasPorMes[meses[i]] ?? 0,
                        color: Colors.red,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final Map<DateTime, double> saldoPorData;
  const LineChartWidget({super.key, required this.saldoPorData});

  @override
  Widget build(BuildContext context) {
    final datas = saldoPorData.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linha do Tempo do Saldo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child:
              datas.isEmpty
                  ? const Center(child: Text('Sem dados suficientes.'))
                  : LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var d in datas)
                              FlSpot(
                                d.millisecondsSinceEpoch.toDouble(),
                                saldoPorData[d] ?? 0,
                              ),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt(),
                              );
                              return Text(
                                '${date.month}/${date.year}',
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
        ),
      ],
    );
  }
}

class AreaChartWidget extends StatelessWidget {
  final Map<DateTime, double> receitasAcumuladas;
  final Map<DateTime, double> despesasAcumuladas;
  const AreaChartWidget({
    super.key,
    required this.receitasAcumuladas,
    required this.despesasAcumuladas,
  });

  @override
  Widget build(BuildContext context) {
    final datas = receitasAcumuladas.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receitas e Despesas Acumuladas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child:
              datas.isEmpty
                  ? const Center(child: Text('Sem dados suficientes.'))
                  : LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var d in datas)
                              FlSpot(
                                d.millisecondsSinceEpoch.toDouble(),
                                receitasAcumuladas[d] ?? 0,
                              ),
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        LineChartBarData(
                          spots: [
                            for (var d in datas)
                              FlSpot(
                                d.millisecondsSinceEpoch.toDouble(),
                                despesasAcumuladas[d] ?? 0,
                              ),
                          ],
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt(),
                              );
                              return Text(
                                '${date.month}/${date.year}',
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
        ),
      ],
    );
  }
}

class RadarChartWidget extends StatelessWidget {
  final List<String> categorias;
  final List<String> meses;
  final Map<String, List<double>> radarData;
  const RadarChartWidget({
    super.key,
    required this.categorias,
    required this.meses,
    required this.radarData,
  });

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty || meses.isEmpty) {
      return const Center(child: Text('Sem dados suficientes.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Radar de Gastos por Categoria (últimos 3 meses)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                for (int i = 0; i < meses.length; i++)
                  RadarDataSet(
                    fillColor: Colors.blue.withOpacity(0.1 + 0.2 * i),
                    borderColor: Colors.blue[(i + 3) * 100] ?? Colors.blue,
                    entryRadius: 2,
                    dataEntries: [
                      for (var cat in categorias)
                        RadarEntry(value: radarData[cat]?[i] ?? 0),
                    ],
                    borderWidth: 2,
                  ),
              ],
              radarBackgroundColor: Colors.transparent,
              radarBorderData: const BorderSide(color: Colors.transparent),
              titleTextStyle: const TextStyle(fontSize: 13),
              getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: categorias[index],
                      angle: angle,
                    );
                 
              },
              tickCount: 4,
              ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              tickBorderData: const BorderSide(color: Colors.grey, width: 1),
              gridBorderData: const BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < meses.length; i++)
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1 + 0.2 * i),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue[(i + 3) * 100] ?? Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  Text(meses[i], style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
