import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ChartsScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  ChartsScreen({required this.transactions});
  
  // Formatador de Moeda
  final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  
  // 1. Lógica de Agrupamento de Dados para o Gráfico
  Map<int, double> _getMonthlyExpenses(List<TransactionModel> allTransactions, List<DateTime> months) {
    Map<int, double> monthlyTotals = {}; 

    for (var date in months) {
      double total = allTransactions
          .where((tx) => 
              tx.type == 'despesa' && 
              tx.date.year == date.year && 
              tx.date.month == date.month
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);
      
      monthlyTotals[date.month] = total;
    }
    return monthlyTotals;
  }

  // 2. Criação das Barras do Gráfico
  List<BarChartGroupData> _buildBarGroups(Map<int, double> monthlyExpenses, List<DateTime> months) {
    
    return months.asMap().entries.map((entry) {
      int index = entry.key;
      DateTime month = entry.value;
      double expense = monthlyExpenses[month.month] ?? 0.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: expense, 
            color: Colors.red.shade700,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // ALTERADO: Obter os últimos 3 meses
    List<DateTime> lastThreeMonths = [];
    for (int i = 2; i >= 0; i--) { 
      lastThreeMonths.add(DateTime(now.year, now.month - i, 1));
    }
    
    final monthlyExpenses = _getMonthlyExpenses(transactions, lastThreeMonths);
    final barGroups = _buildBarGroups(monthlyExpenses, lastThreeMonths);
    double maxAmount = monthlyExpenses.values.isEmpty ? 0 : monthlyExpenses.values.reduce((a, b) => a > b ? a : b);
    
    double interval = maxAmount > 0 ? (maxAmount / 4).ceilToDouble() : 50;

    double lastMonthExpense = monthlyExpenses[lastThreeMonths.last.month] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            // NOVO TÍTULO
            'Despesas Mensais (Últimos 3 Meses)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: BarChart(
              BarChartData(
                maxY: maxAmount > 0 ? maxAmount * 1.2 : 100, 
                minY: 0,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  // Rótulos do Eixo X (Meses)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < lastThreeMonths.length) { // USANDO lastThreeMonths
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM', 'pt_BR').format(lastThreeMonths[index]),
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  // Rótulos do Eixo Y (Valores)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0');
                        return Text(
                          currencyFormatter.format(value).replaceAll('R\$', '').trim(),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.red.shade700,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) { // USANDO 4 PARÂMETROS
                       double expense = monthlyExpenses[lastThreeMonths[groupIndex].month] ?? 0.0; // USANDO lastThreeMonths
                       return BarTooltipItem(
                          currencyFormatter.format(expense),
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                       );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Gasto Total no Mês Atual: ${currencyFormatter.format(lastMonthExpense)}',
              style: TextStyle(fontSize: 16, color: Colors.red.shade800, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 40),
          const Text(
            'Sugestões de Análise',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: Icon(Icons.compare_arrows, color: Colors.blue.shade700),
            title: const Text('Compare o mês de maior despesa com o mês atual.'),
          ),
          ListTile(
            leading: Icon(Icons.savings, color: Colors.green.shade700),
            title: const Text('Tente manter a barra de despesas em queda nos próximos meses!'),
          ),
        ],
      ),
    );
  }
}