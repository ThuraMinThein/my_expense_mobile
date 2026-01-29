import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_expense_mobile/core/providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../expense/providers/expense_provider.dart';
import '../../expense/models/expense_summary.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
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
    final currency = ref.watch(currencyProvider);
    final summaryAsync = ref.watch(
      filteredExpenseSummaryProvider(_selectedPeriod),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
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
      body: summaryAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(expenseProvider.notifier).refresh(),
        ),
        data: (summary) {
          if (summary.count == 0) {
            return EmptyStateWidget(
              icon: Icons.analytics_outlined,
              title: 'No data to analyze',
              subtitle: 'Add some expenses to see your analytics',
            );
          }

          return SingleChildScrollView(
            padding: AppConstants.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total',
                        AppUtils.formatAmount(summary.total, currency),
                        Icons.monetization_on,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Average',
                        AppUtils.formatAmount(summary.average, currency),
                        Icons.trending_up,
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Chart
                _buildChart(summary),

                const SizedBox(height: 24),

                // Category breakdown
                _buildCategoryBreakdown(summary.categoryTotals),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ExpenseSummary summary) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildLineChart(summary)),
        ],
      ),
    );
  }

  Widget _buildLineChart(ExpenseSummary summary) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: summary.total / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.border, strokeWidth: 1);
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (summary.dailyTotals.length - 1).toDouble(),
        minY: 0,
        maxY:
            summary.total *
            1.2, // This might be too high if total is sum of all, better use max daily amount

        lineBarsData: [
          LineChartBarData(
            spots: _getSpots(summary),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(ExpenseSummary summary) {
    final sortedDates = summary.dailyTotals.keys.toList()..sort();

    if (sortedDates.isEmpty) return const [];

    final spots = <FlSpot>[];

    // For daily view, show last 7 days or just the available days
    // This logic might need refinement based on exact requirements for "Weekly/Monthly" tabs
    // For now, mapping the sorted dates to X axis 0..N

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final amount = summary.dailyTotals[date] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    return spots;
  }

  Widget _buildCategoryBreakdown(Map<String, double> categoryTotals) {
    final currency = ref.watch(currencyProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final categoryIndex = AppConstants.expenseCategories.indexOf(
              entry.key,
            );
            final color = AppColors.categoryColors[categoryIndex];
            final percentage = categoryTotals.values.isNotEmpty
                ? (entry.value /
                      categoryTotals.values.reduce((a, b) => a + b) *
                      100)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(entry.key),
                      color: color,
                      size: 16,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Category name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    AppUtils.formatAmount(entry.value, currency),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
