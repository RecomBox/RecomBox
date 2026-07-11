import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/routes/settings/widgets/installed_subtitles.dart';
import 'package:recombox/src/routes/settings/widgets/storage.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'dart:io';

import 'package:recombox/src/global/widgets/title_bar.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsState();
}

class SettingsState extends State<SettingsScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  final List<Map<String, dynamic>> settingItems = [
    // {'icon': Icons.style_rounded, 'label': "Appearance"},
    {'icon': Icons.storage_rounded, 'label': "Storage", 'widget': Storage()},
    {'icon': Icons.subtitles_rounded, 'label': "Installed Subtitles", 'widget': InstalledSubtitles()},


  ];

  int showWidgetIndex = 0;
  
  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {

    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 600)
              NavigationBarVertical(
                currentIndex: 4,
              ),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  spacing: 0,
                  children: [
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                      TitleBar(),
                    
                    Expanded(
                      child: ListView.separated(
                        itemCount: settingItems.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              InkWell(
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  if (context.mounted){
                                    setState(() {
                                      showWidgetIndex = showWidgetIndex == index ? -1 : index;
                                    });
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(bottom: 15, top: 15, left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        settingItems[index]['icon'], 
                                        color: appColors.secondary,
                                        size: 24,
                                      ),
                                      Text(
                                        settingItems[index]['label'],
                                        style: GoogleFonts.nunito(
                                          color: appColors.textPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight(700)
                                        ),
                                      ),

                                      const Spacer(),

                                      Icon(
                                        showWidgetIndex == index ? Icons.arrow_drop_down_rounded : Icons.arrow_left_rounded, 
                                        color: appColors.secondary,
                                        size: 24,
                                      ),
                                    ],
                                  )
                                )
                              ),
                              
                              if (showWidgetIndex == index)
                                settingItems[index]['widget']
                            ],
                          );
                          
                          
                        },

                        separatorBuilder: (context, index) {
                          return Container(
                            height: 1,
                            color: appColors.strokePrimary,
                          );
                        },
                      
                      
                      )
                    )
                  ],
                ),
                bottomNavigationBar: (MediaQuery.of(context).size.width < 600)
                  ? NavigationBarHorizontal(
                    currentIndex: 4,
                  )
                  : null
              )
            ),

          ],
        )
      )
    );
  }
}