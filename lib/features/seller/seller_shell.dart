import 'package:flutter/material.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import 'chatbot/autonomous_chat_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'meetings/meeting_schedule_screen.dart';
import 'products/products_list_screen.dart';
import 'settings/seller_settings_screen.dart';

class SellerShell extends StatefulWidget {
  final int initialIndex;

  const SellerShell({super.key, this.initialIndex = 0});

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  late int _currentIndex;

  final _pages = const [
    DashboardScreen(),
    ProductsListScreen(),
    MeetingScheduleScreen(),
    AutonomousChatScreen(),
    SellerSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: t.card,
          border: Border(
            top: BorderSide(color: t.border, width: t.borderWidth),
          ),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              offset: Offset(0, -t.shadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'DASHBOARD', t),
                _navItem(1, Icons.inventory_2_outlined, Icons.inventory_2, 'PRODUCTS', t),
                _navItem(2, Icons.video_call_outlined, Icons.video_call, 'MEETINGS', t),
                _navItem(3, Icons.smart_toy_outlined, Icons.smart_toy, 'AI BOT', t),
                _navItem(4, Icons.settings_outlined, Icons.settings, 'TOOLS', t),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData outlineIcon, IconData filledIcon, String label, BkTokens t) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          BkMotion.hapticClick();
          setState(() => _currentIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? t.secondary.withAlpha(40) : Colors.transparent,
            border: isSelected
                ? Border.all(color: t.border, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? filledIcon : outlineIcon,
                size: 20,
                color: isSelected ? t.secondary : t.mutedForeground,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? t.foreground : t.mutedForeground,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
