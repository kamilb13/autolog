import 'package:sqflite/sqflite.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/expense_suggestion.dart';
import '../database/app_database.dart';

class ExpenseRepository {
  final AppDatabase _appDb;

  ExpenseRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<List<Expense>> getExpenses({
    String? vehicleId,
    ExpenseCategory? category,
    String? searchQuery,
  }) async {
    final db = await _appDb.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (vehicleId != null && vehicleId.isNotEmpty) {
      whereClauses.add('vehicle_id = ?');
      whereArgs.add(vehicleId);
    }

    if (category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(category.toDbString());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim()}%';
      whereClauses.add('(title LIKE ? OR workshop_or_location LIKE ? OR note LIKE ?)');
      whereArgs.add(query);
      whereArgs.add(query);
      whereArgs.add(query);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC, mileage_km DESC, created_at DESC',
    );

    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<Expense?> getExpenseById(String id) async {
    final db = await _appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<void> addExpense(Expense expense) async {
    final db = await _appDb.database;
    final data = expense.toMap();
    data['created_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.insert('expenses', data, conflictAlgorithm: ConflictAlgorithm.replace);

      // Auto-update vehicle mileage if expense mileage is higher
      final List<Map<String, dynamic>> vehMap = await txn.query(
        'vehicles',
        columns: ['mileage_km'],
        where: 'id = ?',
        whereArgs: [expense.vehicleId],
      );

      if (vehMap.isNotEmpty) {
        final currentKm = (vehMap.first['mileage_km'] as num).toInt();
        if (expense.mileageKm > currentKm) {
          await txn.update(
            'vehicles',
            {'mileage_km': expense.mileageKm},
            where: 'id = ?',
            whereArgs: [expense.vehicleId],
          );
        }
      }
    });
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await _appDb.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await _appDb.database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ExpenseSuggestion>> getLearnedSuggestions() async {
    final db = await _appDb.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT title, category, COUNT(*) as usage_count, MAX(created_at) as last_used
        FROM expenses
        WHERE title IS NOT NULL AND TRIM(title) != ''
        GROUP BY title, category
        ORDER BY usage_count DESC, last_used DESC
      ''');

      return maps.map((m) {
        return ExpenseSuggestion(
          title: m['title'] as String,
          category: ExpenseCategory.fromString(m['category'] as String?),
          isCustom: true,
          count: (m['usage_count'] as num?)?.toInt() ?? 1,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
