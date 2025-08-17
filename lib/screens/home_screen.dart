import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart'; // Import AppState
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good morning!'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: const Text(
              'Here\'s your financial overview',
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
          final totalBalance = totalIncome - totalExpense;

          final recentTransactions = appState.transactions.reversed.take(3).toList();

          final formatter = intl.NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance Card
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
                            const Text(
                              'Total Balance',
                              style: TextStyle(fontSize: 16.0, color: Colors.black54),
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                // TODO: Implement visibility toggle
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          formatter.format(totalBalance),
                          style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: totalBalance >= 0 ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Monthly Income and Expenses Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
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
                              const Icon(Icons.arrow_upward, color: Colors.green),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Monthly Income',
                                style: TextStyle(fontSize: 14.0, color: Colors.black54),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                formatter.format(totalIncome),
                                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Card(
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
                              const Icon(Icons.arrow_downward, color: Colors.red),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Monthly Expenses',
                                style: TextStyle(fontSize: 14.0, color: Colors.black54),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                formatter.format(totalExpense),
                                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Transactions Screen
                        appState.updateSelectedIndex(1);
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                recentTransactions.isEmpty
                    ? const Center(child: Text('No recent transactions.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = recentTransactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            elevation: 1.0,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == 'income' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                child: Icon(
                                  transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(transaction.title),
                              subtitle: Text(transaction.category),
                              trailing: Text(
                                '${transaction.type == 'income' ? '+' : '-'}${formatter.format(transaction.amount)}',
                                style: TextStyle(
                                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
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
