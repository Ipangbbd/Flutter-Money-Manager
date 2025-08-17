import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/services/storage_service.dart';
import 'package:finance_manager/models/transaction.dart';
import 'package:finance_manager/models/category.dart';
import 'package:finance_manager/screens/home_screen.dart';
import 'package:finance_manager/screens/transactions_screen.dart';
import 'package:finance_manager/screens/add_transaction_screen.dart';
import 'package:finance_manager/screens/analytics_screen.dart';
import 'package:finance_manager/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initCategories();
  runApp(
    provider.ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initCategories() async {
  final storageService = StorageService();
  List<Category> categories = await storageService.getCategories();
  if (categories.isEmpty) {
    categories = [
      Category(id: '1', name: 'Salary'),
      Category(id: '2', name: 'Freelance'),
      Category(id: '3', name: 'Investment'),
      Category(id: '4', name: 'Food'),
      Category(id: '5', name: 'Transport'),
      Category(id: '6', name: 'Shopping'),
      Category(id: '7', name: 'Entertainment'),
      Category(id: '8', name: 'Bills'),
      Category(id: '9', name: 'Healthcare'),
    ];
    await storageService.saveCategories(categories);
  }
}

class AppState extends ChangeNotifier {
  int _selectedIndex = 0;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  final StorageService _storageService = StorageService();

  AppState() {
    _loadData();
  }

  int get selectedIndex => _selectedIndex;
  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _transactions = await _storageService.getTransactions();
    _categories = await _storageService.getCategories();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((transaction) => transaction.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((category) => category.id == id);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _storageService.clearAllData();
    _transactions = [];
    _categories = await _storageService
        .getCategories(); // Reload default categories
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const TransactionsScreen(),
    const AddTransactionScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: provider.Consumer<AppState>(
        builder: (context, appState, child) {
          return _pages[appState.selectedIndex];
        },
      ),
      bottomNavigationBar: provider.Consumer<AppState>(
        builder: (context, appState, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: appState.selectedIndex,
            onTap: appState.updateSelectedIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}
