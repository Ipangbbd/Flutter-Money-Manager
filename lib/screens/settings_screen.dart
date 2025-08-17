import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:finance_manager/models/category.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: const Text(
              'Manage your finance app',
              style: TextStyle(fontSize: 16.0, color: Colors.black54),
            ),
          ),
        ),
      ),
      body: provider.Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Management',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.download, color: Colors.blue[700]),
                        title: const Text('Export Data'),
                        subtitle: const Text('Download your financial data'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                        onTap: () {
                          // TODO: Implement export data
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Export data functionality not yet implemented.',
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1.0, indent: 16.0, endIndent: 16.0),
                      ListTile(
                        leading: Icon(Icons.upload, color: Colors.green[700]),
                        title: const Text('Import Data'),
                        subtitle: const Text('Restore from backup'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                        onTap: () {
                          // TODO: Implement import data
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Import data functionality not yet implemented.',
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1.0, indent: 16.0, endIndent: 16.0),
                      ListTile(
                        leading: Icon(
                          Icons.category,
                          color: Colors.purple[700],
                        ),
                        title: const Text('Manage Categories'),
                        subtitle: Text(
                          '${appState.categories.length} categories',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                        onTap: () {
                          _showManageCategoriesDialog(context, appState);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                const Text(
                  'Statistics',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                        ),
                        title: const Text('Total Transactions'),
                        subtitle: Text(
                          '${appState.transactions.length} recorded',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Total transactions display not yet implemented.',
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1.0, indent: 16.0, endIndent: 16.0),
                      ListTile(
                        leading: Icon(
                          Icons.category_outlined,
                          color: Colors.blueGrey[700],
                        ),
                        title: const Text('Categories'),
                        subtitle: Text(
                          '${appState.categories.length} available',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Categories display not yet implemented.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                const Text(
                  'Support',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.help_outline,
                          color: Colors.teal[700],
                        ),
                        title: const Text('Help & Support'),
                        subtitle: const Text('Get help with using the app'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Help & Support functionality not yet implemented.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red[700]),
                    title: Text(
                      'Clear All Data',
                      style: TextStyle(color: Colors.red[700]),
                    ), // Apply red color
                    subtitle: const Text('Permanently delete all data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                    onTap: () {
                      _showClearAllDataConfirmation(context, appState);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manage Categories'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appState.categories.length,
              itemBuilder: (context, index) {
                final category = appState.categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      appState.deleteCategory(category.id);
                      Navigator.of(
                        context,
                      ).pop(); // Close dialog after deletion
                      _showManageCategoriesDialog(
                        context,
                        appState,
                      ); // Re-open to show updated list
                    },
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add New'),
              onPressed: () {
                Navigator.of(context).pop();
                _showAddCategoryDialog(context, appState);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, AppState appState) {
    final TextEditingController newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: newCategoryController,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _showManageCategoriesDialog(context, appState);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (newCategoryController.text.isNotEmpty) {
                  final newCategory = Category(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: newCategoryController.text,
                  );
                  appState.addCategory(newCategory);
                  Navigator.of(context).pop();
                  _showManageCategoriesDialog(context, appState);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDataConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to permanently delete all your financial data? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete All'),
              onPressed: () async {
                await appState.clearAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
