import 'package:flutter/material.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../services/formation_state.dart';
import 'tabs/home_tab.dart';
import 'tabs/empty_tab.dart';

/// Top-level shell shown after the formation flow completes ("Open my
/// business account"). 5-tab bottom navigation; only Home is wired —
/// the rest show a styled empty state until those products ship.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final companyName = FormationProvider.of(context).filedCompanyName;
    final tabs = <Widget>[
      HomeTab(companyName: companyName),
      const EmptyTab(
        title: 'Money',
        subtitle: 'Cards, transfers and FX. Coming soon.',
      ),
      const EmptyTab(
        title: 'Books',
        subtitle: 'Bookkeeping and bank-feed categories. Coming soon.',
      ),
      const EmptyTab(
        title: 'Taxes',
        subtitle: 'CT, VAT, PAYE filings in one place. Coming soon.',
      ),
      const EmptyTab(
        title: 'Company',
        subtitle: 'Cap table, directors, filings history. Coming soon.',
      ),
    ];

    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const _BottomBar({required this.index, required this.onSelect});

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.swap_horiz_rounded, label: 'Money'),
    (icon: Icons.menu_book_rounded, label: 'Books'),
    (icon: Icons.account_balance_rounded, label: 'Taxes'),
    (icon: Icons.business_rounded, label: 'Company'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: QPayTokens.canvasSoft,
        border: Border(
          top: BorderSide(color: QPayTokens.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _Item(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? QPayTokens.ink : QPayTokens.ink3;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: QPayType.fieldLabel.copyWith(
                color: color,
                fontSize: 10.5,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
