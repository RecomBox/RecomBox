import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigate_handler.dart';
import 'package:window_manager/window_manager.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_items.dart';
import 'dart:io';

class NavigationBarVertical extends StatefulWidget {
  const NavigationBarVertical({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  State<NavigationBarVertical> createState() => _NavigationBarVerticalState();
}

class _NavigationBarVerticalState extends State<NavigationBarVertical> {
  late int currentIndex;
  late AppColorsScheme appColors = appColorsNotifier.value;


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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Draggable Window Header
        GestureDetector(
          onPanStart: (_) async {
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
              await windowManager.startDragging();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              'assets/icon/icon-transparent-white.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: NavigationRail(
              labelType: NavigationRailLabelType.all,
              backgroundColor: appColors.primary,
              indicatorColor: appColors.secondary,
              unselectedIconTheme: IconThemeData(color: appColors.secondary),
              selectedIconTheme: IconThemeData(color: appColors.primary),
              selectedLabelTextStyle: TextStyle(color: appColors.textPrimary),
              unselectedLabelTextStyle: TextStyle(color: appColors.textPrimary),
              
              selectedIndex: currentIndex,
              onDestinationSelected: navigate,
              
              // 2. Render destinations from the list
              destinations: navigationItems.map((item) {
                return NavigationRailDestination(
                  icon: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(item['icon']),
                  ),
                  selectedIcon: Icon(item['selectedIcon']),
                  label: Text(item['label']),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}