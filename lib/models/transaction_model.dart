// lib/models/transaction.dart
class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'receita' ou 'despesa'
  final DateTime date;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(), // Salva como string
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String), // Converte a string de volta para DateTime
    );
  }
}