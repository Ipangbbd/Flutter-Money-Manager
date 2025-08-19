import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';
import '../models/category.dart';

class StorageService {
  static const _transactionsKey = 'transactions';
  static const _categoriesKey = 'categories';

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsString = prefs.getString(_transactionsKey);

    if (transactionsString == null) return [];

    final jsonList = json.decode(transactionsString) as List<dynamic>;
    return jsonList.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsString = json.encode(
      transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_transactionsKey, transactionsString);
  }

  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString(_categoriesKey);

    if (categoriesString == null) return [];

    final jsonList = json.decode(categoriesString) as List<dynamic>;
    return jsonList.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = json.encode(
      categories.map((c) => c.toJson()).toList(),
    );
    await prefs.setString(_categoriesKey, categoriesString);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_categoriesKey);
  }
}
