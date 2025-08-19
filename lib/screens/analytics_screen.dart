import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';

final List<String> allMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  int _touchedIndex = -1;
  int _selectedTimeRange = 0; // 0: All Time, 1: Last 3 Months, 2: Last Month
  bool _showIncomeInChart = true;
  bool _showExpenseInChart = true;
  bool _showNetInChart = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final List<String> timeRanges = ['All Time', 'Last 3 Months', 'Last Month'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _tabController = TabController(length: 3, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          final filteredTransactions = _getFilteredTransactions(appState);
          final totalIncome = _calculateTotal(filteredTransactions, 'income');
          final totalExpense = _calculateTotal(filteredTransactions, 'expense');
          final netWorth = totalIncome - totalExpense;

          final categoryExpenses = _groupExpensesByCategory(filteredTransactions);
          final sortedCategoryExpenses = categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final monthlyIncome = _groupTransactionsByMonth(filteredTransactions, 'income');
          final monthlyExpense = _groupTransactionsByMonth(filteredTransactions, 'expense');
          final allMonths = _getAllMonths(monthlyIncome, monthlyExpense);

          final formatter = intl.NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // === Enhanced App Bar ===
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.8),
                            Theme.of(context).primaryColor,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fixed: Wrapped Row in Flexible to prevent overflow
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Flexible(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Analytics',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Insights into your finances',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () => _showTimeRangeBottomSheet(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.9), size: 14),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  timeRanges[_selectedTimeRange],
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.7), size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // === Content ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Enhanced Summary Cards ===
                        _buildSummarySection(context, totalIncome, totalExpense, netWorth, formatter),
                        const SizedBox(height: 32),

                        // === Tab Section ===
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Tab Bar
                              Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.grey[600],
                                  indicator: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  tabs: const [
                                    Tab(text: 'Overview'),
                                    Tab(text: 'Categories'),
                                    Tab(text: 'Trends'),
                                  ],
                                ),
                              ),
                              // Tab Content - Fixed: Added proper constraints
                              SizedBox(
                                height: 400,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildOverviewTab(context, totalIncome, totalExpense, formatter, filteredTransactions),
                                    _buildCategoriesTab(context, sortedCategoryExpenses, formatter, totalExpense),
                                    _buildTrendsTab(context, monthlyIncome, monthlyExpense, allMonths),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, double totalIncome, double totalExpense, double netWorth, intl.NumberFormat formatter) {
    return Column(
      children: [
        // Main balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                netWorth >= 0 ? Colors.green[400]! : Colors.red[400]!,
                netWorth >= 0 ? Colors.green[600]! : Colors.red[600]!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (netWorth >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Net Worth',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            netWorth >= 0 ? Icons.trending_up : Icons.trending_down,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            netWorth >= 0 ? 'Profit' : 'Loss',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Fixed: Added flexible text handling for large amounts
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatter.format(netWorth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Income and Expense cards
        Row(
          children: [
            Expanded(
              child: _buildMiniSummaryCard(
                context,
                icon: Icons.arrow_upward,
                label: 'Income',
                value: formatter.format(totalIncome),
                color: Colors.green,
                backgroundColor: Colors.green[50]!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMiniSummaryCard(
                context,
                icon: Icons.arrow_downward,
                label: 'Expenses',
                value: formatter.format(totalExpense),
                color: Colors.red,
                backgroundColor: Colors.red[50]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniSummaryCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Fixed: Added flexible text handling for currency values
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, double totalIncome, double totalExpense, intl.NumberFormat formatter, List<dynamic> transactions) {
    final savings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Savings rate progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Savings Rate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: savingsRate / 100,
                  backgroundColor: Colors.blue[100],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatter.format(savings),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Transactions',
                  '${transactions.length}',
                  Icons.receipt_long,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  'Avg. Income',
                  formatter.format(totalIncome / max(1, transactions.where((t) => t.type == 'income').length)),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Avg. Expense',
                  formatter.format(totalExpense / max(1, transactions.where((t) => t.type == 'expense').length)),
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  'Categories',
                  '${_groupExpensesByCategory(transactions).length}',
                  Icons.category,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // Fixed: Added flexible text handling
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context, List<MapEntry<String, double>> sortedCategoryExpenses, intl.NumberFormat formatter, double totalExpense) {
    if (sortedCategoryExpenses.isEmpty || totalExpense == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No expense data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding expenses to see category breakdown',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Pie Chart - Fixed: Wrapped in Flexible to prevent overflow
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // Chart
                    Expanded(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse?.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: sortedCategoryExpenses.take(6).toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final amount = data.value;
                              final isTouched = index == _touchedIndex;
                              final radius = isTouched ? 70.0 : 60.0;
                              final percentage = (amount / totalExpense) * 100;

                              return PieChartSectionData(
                                color: _getCategoryColor(index),
                                value: amount,
                                title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                                radius: radius,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ),

                    // Legend - Fixed: Added proper constraints
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: sortedCategoryExpenses.take(6).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            final categoryName = data.key;
                            final amount = data.value;
                            final percentage = (amount / totalExpense) * 100;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(index),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          categoryName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context, Map<String, double> monthlyIncome, Map<String, double> monthlyExpense, List<String> allMonths) {
    if (allMonths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No trend data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add more transactions to see trends',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed: Wrapped title and toggles in Flexible widgets
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Monthly Trends',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChartToggle('Income', Colors.green, _showIncomeInChart, (value) {
                          setState(() => _showIncomeInChart = value);
                        }),
                        const SizedBox(width: 8),
                        _buildChartToggle('Expense', Colors.red, _showExpenseInChart, (value) {
                          setState(() => _showExpenseInChart = value);
                        }),
                        const SizedBox(width: 8),
                        _buildChartToggle('Net', Colors.blue, _showNetInChart, (value) {
                          setState(() => _showNetInChart = value);
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _buildEnhancedTrendsChart(monthlyIncome, monthlyExpense, allMonths),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(String label, Color color, bool isSelected, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTrendsChart(Map<String, double> monthlyIncome, Map<String, double> monthlyExpense, List<String> allMonths) {
    final maxY = [
      monthlyIncome.values.isEmpty ? 0.0 : monthlyIncome.values.reduce(max),
      monthlyExpense.values.isEmpty ? 0.0 : monthlyExpense.values.reduce(max),
    ].reduce(max) * 1.2;

    List<LineChartBarData> lineBars = [];

    if (_showIncomeInChart) {
      lineBars.add(LineChartBarData(
        spots: allMonths.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final month = entry.value;
          final income = monthlyIncome[month] ?? 0.0;
          return FlSpot(index, income);
        }).toList(),
        isCurved: true,
        color: Colors.green[600]!,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.green[600]!,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.green.withValues(alpha: 0.1),
        ),
      ));
    }

    if (_showExpenseInChart) {
      lineBars.add(LineChartBarData(
        spots: allMonths.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final month = entry.value;
          final expense = monthlyExpense[month] ?? 0.0;
          return FlSpot(index, expense);
        }).toList(),
        isCurved: true,
        color: Colors.red[600]!,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.red[600]!,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.red.withValues(alpha: 0.1),
        ),
      ));
    }

    if (_showNetInChart) {
      lineBars.add(LineChartBarData(
        spots: allMonths.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final month = entry.value;
          final net = (monthlyIncome[month] ?? 0.0) - (monthlyExpense[month] ?? 0.0);
          return FlSpot(index, net);
        }).toList(),
        isCurved: true,
        color: Colors.blue[600]!,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.blue[600]!,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
      ));
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < allMonths.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      allMonths[index].substring(0, 3),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5,
              reservedSize: 60,
              getTitlesWidget: (value, _) => Text(
                intl.NumberFormat.compactCurrency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(value),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final month = allMonths[spot.x.toInt()];
                final formatter = intl.NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );

                Color color = Colors.blue[600]!;
                String label = 'Net';

                if (spot.barIndex == 0 && _showIncomeInChart) {
                  color = Colors.green[600]!;
                  label = 'Income';
                } else if (spot.barIndex == 1 && _showExpenseInChart) {
                  color = Colors.red[600]!;
                  label = 'Expense';
                }

                return LineTooltipItem(
                  '$month\n$label: ${formatter.format(spot.y)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: lineBars,
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
    ];
    return colors[index % colors.length];
  }

  void _showTimeRangeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Time Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...timeRanges.asMap().entries.map((entry) {
                final index = entry.key;
                final range = entry.value;
                return ListTile(
                  leading: Icon(
                    index == 0 ? Icons.all_inclusive :
                    index == 1 ? Icons.calendar_view_month : Icons.calendar_today,
                  ),
                  title: Text(range),
                  trailing: _selectedTimeRange == index
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    setState(() => _selectedTimeRange = index);
                    Navigator.pop(context);
                  },
                );
              })
            ],
          ),
        );
      },
    );
  }

  /// ----------------------
  /// 🔹 Helper Methods
  /// ----------------------

  List<dynamic> _getFilteredTransactions(AppState appState) {
    final now = DateTime.now();
    return appState.transactions.where((transaction) {
      switch (_selectedTimeRange) {
        case 1: // Last 3 months
          return transaction.date.isAfter(DateTime(now.year, now.month - 3, now.day));
        case 2: // Last month
          return transaction.date.isAfter(DateTime(now.year, now.month - 1, now.day));
        default: // All time
          return true;
      }
    }).toList();
  }

  double _calculateTotal(List<dynamic> transactions, String type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _groupExpensesByCategory(List<dynamic> transactions) {
    final Map<String, double> categoryExpenses = {};
    for (var t in transactions.where((t) => t.type == 'expense')) {
      categoryExpenses.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    return categoryExpenses;
  }

  Map<String, double> _groupTransactionsByMonth(List<dynamic> transactions, String type) {
    final Map<String, double> monthlyData = {};
    for (var t in transactions.where((t) => t.type == type)) {
      final monthYear = intl.DateFormat('MMM yyyy').format(t.date);
      monthlyData.update(monthYear, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    return monthlyData;
  }

  List<String> _getAllMonths(Map<String, double> monthlyIncome, Map<String, double> monthlyExpense) {
    final allMonths = {...monthlyIncome.keys, ...monthlyExpense.keys}.toList();
    allMonths.sort((a, b) => intl.DateFormat('MMM yyyy')
        .parse(a)
        .compareTo(intl.DateFormat('MMM yyyy').parse(b)));
    return allMonths;
  }
}