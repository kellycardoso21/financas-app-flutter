import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            type TEXT,
            date TEXT  -- NOVO: Coluna de data
          )
        ''');
      },
    );
  }

  static Future<void> insertTransaction(TransactionModel tx) async {
    final db = await database;
    await db.insert(
      'transactions', 
      tx.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final data = await db.query('transactions', orderBy: 'date DESC, id DESC'); 
    return data.map((e) => TransactionModel.fromMap(e)).toList();
  }

  static Future<void> updateTransaction(TransactionModel tx) async {
    final db = await database;
    await db.update(
      'transactions', 
      tx.toMap(), 
      where: 'id = ?', 
      whereArgs: [tx.id],
    );
  }

  static Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}