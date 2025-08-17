import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:finance_manager/models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
      body: provider.Consumer<AppState>(
        builder: (context, appState, child) {
          List<Transaction> filteredTransactions = appState.transactions.where((
            transaction,
          ) {
            final matchesFilter =
                _selectedFilter == 'All' ||
                (_selectedFilter == 'Income' && transaction.type == 'income') ||
                (_selectedFilter == 'Expense' && transaction.type == 'expense');
            final matchesSearch =
                transaction.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                transaction.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
            return matchesFilter && matchesSearch;
          }).toList();

          filteredTransactions.sort(
            (a, b) => b.date.compareTo(a.date),
          ); // Sort by date descending

          final formatter = intl.NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 2,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == 'All',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'All';
                        });
                      },
                    ),
                    const SizedBox(width: 8.0),
                    FilterChip(
                      label: const Text('Income'),
                      selected: _selectedFilter == 'Income',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'Income';
                        });
                      },
                    ),
                    const SizedBox(width: 8.0),
                    FilterChip(
                      label: const Text('Expense'),
                      selected: _selectedFilter == 'Expense',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'Expense';
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredTransactions.isEmpty
                    ? const Center(child: Text('No transactions found.'))
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            elevation: 1.0,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == 'income'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                child: Icon(
                                  transaction.type == 'income'
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: transaction.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              title: Text(transaction.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(transaction.category),
                                  Text(
                                    intl.DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(transaction.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${transaction.type == 'income' ? '+' : '-'}${formatter.format(transaction.amount)}',
                                    style: TextStyle(
                                      color: transaction.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      appState.deleteTransaction(
                                        transaction.id,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
