class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'receita' ou 'despesa'
  final DateTime date; // NOVO: Campo de data

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date, // NOVO
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(), // Salva a data como string
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      type: map['type'] as String,
      // Converte a string de volta para DateTime
      date: map['date'] != null 
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}