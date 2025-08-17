import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';
  static const String _categoriesKey = 'categories';

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString(_transactionsKey);
    if (transactionsString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(transactionsString);
    return jsonList.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String transactionsString = json.encode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_transactionsKey, transactionsString);
  }

  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesString = prefs.getString(_categoriesKey);
    if (categoriesString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(categoriesString);
    return jsonList.map((json) => Category.fromJson(json)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final String categoriesString = json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, categoriesString);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_categoriesKey);
  }
}
