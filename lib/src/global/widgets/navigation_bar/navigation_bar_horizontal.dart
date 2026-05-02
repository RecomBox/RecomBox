import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigate_handler.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_items.dart';

class NavigationBarHorizontal extends StatefulWidget {
  const NavigationBarHorizontal({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  State<NavigationBarHorizontal> createState() =>
      _NavigationBarHorizontalState();
}

class _NavigationBarHorizontalState extends State<NavigationBarHorizontal> {
  late int currentIndex;
  var appColors = appColorsNotifier.value;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  void navigate(int index) {
    setState(() {
      currentIndex = index;
    });
    navigateHander(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: appColors.strokePrimary,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: NavigationBar(
              backgroundColor: appColors.primary,
              indicatorColor: appColors.secondary,
              labelTextStyle: WidgetStateProperty.all(
                TextStyle(color: appColors.textPrimary),
              ),
              selectedIndex: currentIndex,
              onDestinationSelected: navigate,
              // 2. Map the list to NavigationDestination widgets
              destinations: navigationItems.map((item) {
                return NavigationDestination(
                  icon: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(item['icon'], color: appColors.secondary),
                  ),
                  selectedIcon: Icon(item['selectedIcon'], color: appColors.primary),
                  label: item['label'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}