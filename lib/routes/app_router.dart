import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/expense/screens/add_expense_screen.dart';
import '../features/expense/screens/expense_history_screen.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../core/providers/app_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(userProvider);

  return GoRouter(
    initialLocation: user == null ? '/welcome' : '/home',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const AddExpenseScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const ExpenseHistoryScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = ref.read(userProvider);
      final isAuthenticated = user != null;
      final currentPath = state.uri.path;

      if (!isAuthenticated) {
        if (currentPath.startsWith('/home') ||
            currentPath.startsWith('/history') ||
            currentPath.startsWith('/analytics') ||
            currentPath.startsWith('/profile')) {
          return '/welcome';
        }
      }

      if (isAuthenticated && currentPath == '/welcome') {
        return '/home';
      }

      return null;
    },
  );
});

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.add_circle_outline,
      selectedIcon: Icons.add_circle,
      label: 'Add',
      route: '/home',
    ),
    const NavigationItem(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'History',
      route: '/history',
    ),
    const NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Analytics',
      route: '/analytics',
    ),
    const NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final route = GoRouter.of(context);
    final currentPath = route.routeInformationProvider.value.uri.path;
    for (int i = 0; i < _navigationItems.length; i++) {
      if (currentPath == _navigationItems[i].route) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
    context.go(_navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
