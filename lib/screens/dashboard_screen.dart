import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../helpers/db_helper.dart';
import 'summary_screen.dart';
import 'charts_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  int _selectedIndex = 0; 
  
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    final data = await DBHelper.getTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Lógica para adicionar/editar transação (MODAL ATUALIZADO)
  void _addOrEditTransaction({TransactionModel? existingTransaction}) async {
    String _selectedType = 'receita';
    DateTime? _selectedDate = DateTime.now(); // Variável para controlar a data

    if (existingTransaction != null) {
      _titleController.text = existingTransaction.title;
      _amountController.text = existingTransaction.amount.toString();
      _selectedType = existingTransaction.type;
      _selectedDate = existingTransaction.date;
    } else {
      _titleController.clear();
      _amountController.clear();
      _selectedDate = DateTime.now(); // Valor padrão
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: Text(existingTransaction == null
                ? 'Adicionar Transação'
                : 'Editar Transação'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Valor'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'receita', child: Text('Receita')),
                      DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setStateModal(() {
                          _selectedType = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Tipo'),
                  ),
                  const SizedBox(height: 10),
                  // NOVO: Seletor de Data
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setStateModal(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('Alterar Data'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(existingTransaction == null ? 'Adicionar' : 'Salvar'),
                onPressed: () async {
                  final title = _titleController.text.trim();
                  // Tenta converter o texto para double, tratando vírgula como ponto
                  final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

                  if (title.isEmpty || amount <= 0 || _selectedDate == null) {
                    return;
                  }

                  final newTransaction = TransactionModel(
                    id: existingTransaction?.id, 
                    title: title,
                    amount: amount,
                    type: _selectedType,
                    date: _selectedDate!, // SALVANDO A DATA
                  );

                  if (existingTransaction == null) {
                    await DBHelper.insertTransaction(newTransaction);
                  } else {
                    await DBHelper.updateTransaction(newTransaction);
                  }

                  Navigator.pop(context);
                  _loadTransactions(); 
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteTransaction(int id) async {
    await DBHelper.deleteTransaction(id);
    _loadTransactions(); 
  }

  List<TransactionModel> get _currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) {
      return tx.date.month == now.month && tx.date.year == now.year;
    }).toList();
  }

  double get _currentMonthBalance {
    double total = 0.0;
    for (var tx in _currentMonthTransactions) {
      if (tx.type == 'receita') {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  double get _currentMonthDespesas {
    return _currentMonthTransactions
        .where((tx) => tx.type == 'despesa')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 5),
              Text(
                currencyFormatter.format(value.abs()), 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      _buildDashboardBody(),
      SummaryScreen(transactions: _transactions),
      ChartsScreen(transactions: _transactions),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Finanças'),
        automaticallyImplyLeading: false, 
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 98, 191, 98), 
            radius: 15, 
            child: Text(
              'F',
              style: TextStyle(
                color: const Color.fromARGB(255, 229, 232, 229),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _addOrEditTransaction(),
              child: const Icon(Icons.add),
            )
          : null, 
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Resumo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Gráficos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardBody() {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadTransactions,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bem-vindas, Kelly e Julia!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Cards de resumo (Mês Atual)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard(
                          'Saldo do Mês', 
                          _currentMonthBalance, 
                          _currentMonthBalance >= 0 ? Colors.green.shade700 : Colors.red.shade700
                      ),
                      const SizedBox(width: 10),
                      _buildSummaryCard(
                          'Despesas do Mês', 
                          _currentMonthDespesas, 
                          Colors.red.shade700
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Text(
                    'Últimas Transações (${DateFormat('MMMM/yyyy', 'pt_BR').format(DateTime.now())})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: _currentMonthTransactions.isEmpty
                        ? const Center(
                            child: Text('Nenhuma transação neste mês. Adicione uma!'),
                          )
                        : ListView.builder(
                            itemCount: _currentMonthTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _currentMonthTransactions[index];
                              final isRevenue = tx.type == 'receita';
                              
                              return Card(
                                elevation: 1,
                                color: isRevenue ? Colors.green.shade50 : Colors.red.shade50,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isRevenue ? Colors.green.shade700 : Colors.red.shade700,
                                    child: Icon(isRevenue ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                                  ),
                                  title: Text(tx.title),
                                  subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${isRevenue ? '+' : '-'} ${currencyFormatter.format(tx.amount)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isRevenue ? Colors.green.shade800 : Colors.red.shade800,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _addOrEditTransaction(existingTransaction: tx),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteTransaction(tx.id!),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}