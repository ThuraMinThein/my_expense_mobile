import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../expense/providers/expense_provider.dart';

import '../../../core/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final currency = ref.watch(currencyProvider);
    final isDarkMode = ref.watch(themeProvider);
    final summaryAsync = ref.watch(expenseSummaryProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: AppConstants.defaultPadding,
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Profile info
            AppCard(
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      AppUtils.getInitials(user!.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            summaryAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (summary) => AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        'Total Expenses',
                        '${summary.count}',
                        Icons.receipt_long,
                      ),
                    ),
                    Expanded(
                      child: _buildStat(
                        'Total Spent',
                        AppUtils.formatAmount(summary.total),
                        Icons.monetization_on,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Settings
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 16),

                  // Currency selector
                  ListTile(
                    leading: const Icon(Icons.currency_exchange),
                    title: const Text('Currency'),
                    subtitle: Text(currency),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCurrencySelector(context, ref),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Dark mode toggle
                  SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: Text(isDarkMode ? 'Enabled' : 'Disabled'),
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).state = value;
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // About
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    subtitle: const Text('Version ${AppConstants.appVersion}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAboutDialog(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _logout(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  void _showCurrencySelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppConstants.defaultPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...AppConstants.currencies.map(
              (currency) => ListTile(
                title: Text(currency),
                onTap: () {
                  ref.read(currencyProvider.notifier).state = currency;
                  Navigator.pop(context);
                },
                trailing: ref.watch(currencyProvider) == currency
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.account_balance_wallet),
      children: [const Text('A simple and beautiful expense tracking app.')],
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).state = null;
              context.go('/welcome');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
