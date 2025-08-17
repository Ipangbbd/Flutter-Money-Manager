import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:intl/intl.dart' as intl;

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: const Text(
              'Insights into your spending',
              style: TextStyle(fontSize: 16.0, color: Colors.black54),
            ),
          ),
        ),
      ),
      body: provider.Consumer<AppState>(
        builder: (context, appState, child) {
          final totalIncome = appState.transactions
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, item) => sum + item.amount);
          final totalExpense = appState.transactions
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, item) => sum + item.amount);
          final netWorth = totalIncome - totalExpense;

          final Map<String, double> categoryExpenses = {};
          appState.transactions.where((t) => t.type == 'expense').forEach((t) {
            categoryExpenses.update(
              t.category,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          });

          final sortedCategoryExpenses = categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final formatter = intl.NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 2,
          );

          // Monthly Trends Calculation
          final Map<String, double> monthlyIncome = {};
          final Map<String, double> monthlyExpense = {};

          for (var transaction in appState.transactions) {
            final monthYear = intl.DateFormat(
              'MMM yyyy',
            ).format(transaction.date);
            if (transaction.type == 'income') {
              monthlyIncome.update(
                monthYear,
                (value) => value + transaction.amount,
                ifAbsent: () => transaction.amount,
              );
            } else {
              monthlyExpense.update(
                monthYear,
                (value) => value + transaction.amount,
                ifAbsent: () => transaction.amount,
              );
            }
          }

          // Get unique sorted months for trends
          final allMonths =
              (monthlyIncome.keys.toSet()..addAll(monthlyExpense.keys.toSet()))
                  .toList();
          allMonths.sort((a, b) {
            return intl.DateFormat(
              'MMM yyyy',
            ).parse(a).compareTo(intl.DateFormat('MMM yyyy').parse(b));
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Income Card
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.green),
                            const Text(
                              'Total Income',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          formatter.format(totalIncome),
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Total Expenses Card
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.red),
                            const Text(
                              'Total Expenses',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          formatter.format(totalExpense),
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Net Worth Card
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Net Worth',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          formatter.format(netWorth),
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: netWorth >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                const Text(
                  'Expenses by Category',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                sortedCategoryExpenses.isEmpty
                    ? const Center(child: Text('No expense categories found.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedCategoryExpenses.length,
                        itemBuilder: (context, index) {
                          final entry = sortedCategoryExpenses[index];
                          final categoryName = entry.key;
                          final amount = entry.value;
                          final percentage = (amount / totalExpense) * 100;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            elevation: 1.0,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.withOpacity(0.1),
                                child: const Icon(
                                  Icons.category,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(categoryName),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatter.format(amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24.0),

                const Text(
                  'Monthly Trends',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                allMonths.isEmpty
                    ? const Center(child: Text('No monthly trends available.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allMonths.length,
                        itemBuilder: (context, index) {
                          final month = allMonths[index];
                          final income = monthlyIncome[month] ?? 0.0;
                          final expense = monthlyExpense[month] ?? 0.0;
                          final totalMonthAmount = income + expense;
                          final incomePercentage = totalMonthAmount == 0
                              ? 0.0
                              : income / totalMonthAmount;
                          final expensePercentage = totalMonthAmount == 0
                              ? 0.0
                              : expense / totalMonthAmount;

                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    month,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: (incomePercentage * 100).toInt(),
                                        child: Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: (expensePercentage * 100).toInt(),
                                        child: Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatter.format(income),
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        formatter.format(expense),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
