import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    // Separate default and custom categories
    final defaultCategories = categories.where((cat) => cat.isDefault).toList();
    final customCategories = categories.where((cat) => !cat.isDefault).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Default Categories Section
          Text(
            'Default Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: _buildCategoryGrid(defaultCategories, context, false),
          ),

          // Custom Categories Section (if any)
          if (customCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Custom Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: _buildCategoryGrid(customCategories, context, true),
            ),
          ],

          // Info text
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can add custom categories when creating a new transaction.',
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<Category> categories,
    BuildContext context,
    bool canDelete,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        final category = categories[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: category.color.withOpacity(0.3), width: 1),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category.icon, color: category.color, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (canDelete)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red.withOpacity(0.7),
                    onPressed: () {
                      _showDeleteConfirmation(context, category);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).deleteCategory(category.id);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
