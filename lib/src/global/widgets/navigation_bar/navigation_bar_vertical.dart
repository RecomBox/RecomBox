import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:window_manager/window_manager.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_items.dart';
import 'dart:io';

class NavigationBarVertical extends StatefulWidget {
  const NavigationBarVertical({
    super.key,
    required this.currentName,
  });

  final String currentName;

  @override
  State<NavigationBarVertical> createState() => _NavigationBarVerticalState();
}

class _NavigationBarVerticalState extends State<NavigationBarVertical> {
  late int currentIndex;
  late AppColorsScheme appColors = appColorsNotifier.value;


  @override
  void initState() {
    super.initState();
    currentIndex = navigationItems.indexWhere((item) => item['name'] == widget.currentName);
    if (currentIndex == -1) currentIndex = 0;
    debugPrint(navigationItems.toString());
  }

  void navigate(int index) {
    debugPrint(index.toString());
    setState(() {
      currentIndex = index;
    });
    Navigator.pushNamed(
      context, navigationItems[index]['route']
    );
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
              
              // Render destinations from the list
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