import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:recombox/src/global/app_color.dart';

class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  var appColors = appColorsNotifier.value;

  @override
  void initState() {
    super.initState();
  }

  Future<void> minimize() async {
    await windowManager.minimize();
  }

  Future<void> fullscreen() async {
    await windowManager.setFullScreen(false);
    await windowManager.isMaximized()
        ? await windowManager.unmaximize()
        : await windowManager.maximize();
  }

  Future<void> close() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanStart: (_) async {
          await windowManager.startDragging();
        },
        child: Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: minimize,
                  style: TextButton.styleFrom(
                    
                    backgroundColor: appColors.tertiary.withAlpha(125),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero, // <-- change radius here
                      ),
                    
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      Icons.minimize_rounded,
                      color: appColors.secondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: fullscreen,
                  style: TextButton.styleFrom(
                    
                    backgroundColor: appColors.tertiary.withAlpha(125),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero, // <-- change radius here
                      ),
                    
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      Icons.rectangle_outlined,
                      color: appColors.secondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: close,
                  style: TextButton.styleFrom(
                    backgroundColor: appColors.tertiary.withAlpha(125),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    
                    overlayColor: Colors.red.withAlpha(255),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      Icons.close_rounded,
                      color: appColors.secondary,
                    ),
                  ),
                ),
              ],
            )));
  }
}
