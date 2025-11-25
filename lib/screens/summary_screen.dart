import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class SummaryScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  SummaryScreen({required this.transactions});
  
  // Formatador de Moeda
  final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }
  
  // Filtra transações do mês atual
  List<TransactionModel> get _currentMonthTransactions => 
    transactions.where((tx) => _isCurrentMonth(tx.date)).toList();

  double get totalEntradas {
    return _currentMonthTransactions
        .where((tx) => tx.type == 'receita')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalDespesas {
    return _currentMonthTransactions
        .where((tx) => tx.type == 'despesa')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get saldoFinal => totalEntradas - totalDespesas;

  int get numDespesas => _currentMonthTransactions
      .where((tx) => tx.type == 'despesa')
      .length;

  double get mediaPorDespesa =>
      numDespesas > 0 ? totalDespesas / numDespesas : 0.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ... dentro do método build ...
          children: [
            Text(
              // APLICANDO o locale 'pt_BR' explicitamente para garantir o nome do mês.
              'Resumo de ${DateFormat('MMMM/yyyy', 'pt_BR').format(DateTime.now())}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
// ...),

            // Saldo Final
            Center(
              child: Column(
                children: [
                  const Text('Saldo Restante (Mês)', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(currencyFormatter.format(saldoFinal),
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: saldoFinal >= 0 ? Colors.blue.shade700 : Colors.red.shade700)),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            // Card de Entradas
            Card(
              elevation: 2,
              color: Colors.green.shade100,
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                title: const Text('Total de Entradas', style: TextStyle(fontSize: 16)),
                trailing: Text('+ ${currencyFormatter.format(totalEntradas)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ),
            ),

            // Card de Despesas
            Card(
              elevation: 2,
              color: Colors.red.shade100,
              child: ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red, size: 30),
                title: const Text('Total de Despesas', style: TextStyle(fontSize: 16)),
                trailing: Text('- ${currencyFormatter.format(totalDespesas)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Informações Adicionais
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Métricas de Gasto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total de Despesas Lançadas:'),
                        Text(numDespesas.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Média por Despesa:'),
                        Text(currencyFormatter.format(mediaPorDespesa), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}