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
import 'package:finance_manager/screens/welcome_screen.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initCategories();

  runApp(
    provider.ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initCategories() async {
  final storageService = StorageService();
  var categories = await storageService.getCategories();

  if (categories.isEmpty) {
    const categories = [
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

  AppState();

  Future<void> initializeData() async => _loadData();

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
    _transactions.removeWhere((t) => t.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _storageService.clearAllData();
    _transactions = [];
    _categories = await _storageService.getCategories(); // reload default
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _hasLaunchedBefore;

  @override
  void initState() {
    super.initState();
    _hasLaunchedBefore = _checkFirstLaunch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.Provider.of<AppState>(context, listen: false).initializeData();
    });
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_launched_before') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: _buildTheme(context),
      home: FutureBuilder<bool>(
        future: _hasLaunchedBefore,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (snapshot.data ?? false)
                ? const MainScreen()
                : const WelcomeScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6200EE),
        primary: const Color(0xFF6200EE),
        secondary: const Color(0xFF03DAC6),
        tertiary: const Color(0xFFBB86FC),
        error: const Color(0xFFB00020),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        onError: Colors.white,
        // background: const Color(0xFFF8F8F8),
        // onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarTextStyle: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).bodyMedium,
        titleTextStyle: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6200EE),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6200EE),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: const Color(0xFF6200EE).withValues(alpha: 0.1),
        checkmarkColor: const Color(0xFF6200EE),
        labelStyle: GoogleFonts.poppins(color: Colors.black87),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pages = const [
    HomeScreen(),
    TransactionsScreen(),
    AddTransactionScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _pages[appState.selectedIndex],
          );
        },
      ),
      bottomNavigationBar: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: appState.selectedIndex,
            onTap: appState.updateSelectedIndex,
            selectedItemColor: const Color(0xFF6200EE),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
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
