import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isWide = MediaQuery.of(context).size.width > 800;

    int currentIndex = 0;
    if (location.startsWith('/transactions')) currentIndex = 1;
    else if (location == '/categories') currentIndex = 2;
    else if (location == '/budget') currentIndex = 3;
    else if (location == '/goals') currentIndex = 4;
    else if (location == '/settings') currentIndex = 5;

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      const NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Transazioni'),
      const NavigationDestination(icon: Icon(Icons.category), label: 'Categorie'),
      const NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
      const NavigationDestination(icon: Icon(Icons.flag), label: 'Obiettivi'),
      const NavigationDestination(icon: Icon(Icons.settings), label: 'Impostazioni'),
    ];

    final railDestinations = destinations.map((d) => NavigationRailDestination(
      icon: d.icon,
      label: Text(d.label),
    )).toList();

    void onTap(int index) {
      switch (index) {
        case 0: context.go('/'); break;
        case 1: context.go('/transactions'); break;
        case 2: context.go('/categories'); break;
        case 3: context.go('/budget'); break;
        case 4: context.go('/goals'); break;
        case 5: context.go('/settings'); break;
      }
    }

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('💸', style: const TextStyle(fontSize: 32)),
              ),
              destinations: railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex > 4 ? 4 : currentIndex,
        onDestinationSelected: (i) {
          if (i < 5) onTap(i);
        },
        destinations: [
          destinations[0],
          destinations[1],
          destinations[2],
          destinations[3],
          NavigationDestination(icon: const Icon(Icons.more_horiz), label: 'Altro'),
        ],
      ),
    );
  }
}
