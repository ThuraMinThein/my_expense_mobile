import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseHistoryScreen extends ConsumerStatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  ConsumerState<ExpenseHistoryScreen> createState() =>
      _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends ConsumerState<ExpenseHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'daily';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(filteredExpensesProvider(_selectedPeriod));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _selectedPeriod = ['daily', 'weekly', 'monthly'][index];
            });
          },
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: expensesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(expenseProvider.notifier).refresh(),
        ),
        data: (expenses) {
          if (expenses.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No expenses yet',
              subtitle: 'Start adding expenses to see them here',
            );
          }

          return ListView.builder(
            padding: AppConstants.defaultPadding,
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _buildExpenseCard(expense);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    // final categoryIndex = AppConstants.expenseCategories.indexOf(
    //   expense.category,
    // );
    final categoryColor =
        AppColors.categoryColors[expense.category] ??
        AppColors.categoryColors["Other"];

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: categoryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Expense details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (expense.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    expense.note,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatDateTime(expense.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            AppUtils.formatAmount(expense.amount, currency: expense.currency),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }
}
