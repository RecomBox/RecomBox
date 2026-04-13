import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';

import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:recombox/src/routes/select_plugin/widgets/select_plugin_tile.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';

import 'dart:io';


class SelectPluginScreenArguments {
  Source source;
  String id;
  String title;
  String titleSecondary;
  BigInt season;
  BigInt episode;


  SelectPluginScreenArguments({
    required this.source,
    required this.id,
    required this.title,
    required this.season,
    required this.titleSecondary,
    required this.episode
  });
}

class SelectPluginScreen extends StatefulWidget {
  const SelectPluginScreen({super.key});

  @override
  State<SelectPluginScreen> createState() => _SelectPluginState();
}

class _SelectPluginState extends State<SelectPluginScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  Map<String, InstalledPluginInfo> installedPluginMap = {};


  final TextEditingController _textEditingController = TextEditingController(text: '');
  FocusNode searchFocus = FocusNode();

  late SelectPluginScreenArguments args;
  
  @override
  void initState() {
    super.initState();

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;

      args = rawArgs is SelectPluginScreenArguments
          ? rawArgs
          : SelectPluginScreenArguments(
              source: Source.movies,
              id: "%2F53906%2Fspider-man",
              title: "Spiderman",
              titleSecondary: "Spiderman",
              season: BigInt.from(1),
              episode: BigInt.from(1)
              
          );

      debugPrint(args.toString());
      initSelectPlugin();

      
      
    });
  }

  @override
  void dispose() {

    super.dispose();
    
    
  }

  Future<void> initSelectPlugin() async {
    
    Map<String, InstalledPluginInfo> getInstalledPluginMap = await getInstalledPlugins(source: args.source.name);

    setState(() {
      installedPluginMap = getInstalledPluginMap;
    });

    debugPrint(getInstalledPluginMap.toString());

  }

  Map<String, InstalledPluginInfo> onFilterSearch() {
    final query = _textEditingController.text.toLowerCase();

    return Map.fromEntries(
      installedPluginMap.entries.where((entry) {
        final element = entry.value;
        return element.pluginName.toLowerCase().contains(query) ||
              element.pluginVersion.toLowerCase().contains(query) ||
              element.manifestRepoName.toLowerCase().contains(query) ||
              element.pluginRepoUrl.toLowerCase().contains(query);
      }),
    );
  }





  @override
  Widget build(BuildContext context) {

        Map<String, InstalledPluginInfo> filteredInstalledPluginMap = onFilterSearch();


    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              TitleBar(),
            Expanded(
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    spacing: 0,
                    children: [
                      
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          spacing: 10,
                          children: [
                            IconButton(
                              mouseCursor: SystemMouseCursors.click,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: appColors.secondary,
                              ),
                            ),
                            Text(
                              'Select plugin',
                              style: GoogleFonts.nunito(
                                color: appColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight(600),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                      // -> Search Widget

                      
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: appColors.strokePrimary
                              )
                            )
                          ),
                          width: double.infinity,
                          height: 60,
                          child: GestureDetector(
                            onTap: (){
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: double.infinity,
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: appColors.textPrimary,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _textEditingController,
                                      onChanged: (_){
                                        
                                      },
                                      onSubmitted: (value){
                                        
                                      },
                                      cursorColor: appColors.textPrimary,
                                      focusNode: searchFocus,
                                      style: GoogleFonts.nunito(
                                        fontSize: 24,
                                        color: appColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search",
                                        hintStyle: TextStyle(
                                          color: appColors.textPrimary,
                                        )
                                      ),
                                    )
                                  )
                                ],
                              )
                            )
                          )
                        ),

                      ),
                    
                      // <-

                      if (installedPluginMap.isNotEmpty)

                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredInstalledPluginMap.length,
                            itemBuilder: (context, index) {
                              return SelectPluginTile(
                                pluginInfo: filteredInstalledPluginMap.values.toList()[index],
                                selectPluginScreenArguments: args,
                              );
                            },
                          ),
                        ),
                      if (installedPluginMap.isEmpty)
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "No plugins found.\n You can add plugins using the 'Add plugins' button.",
                                style: GoogleFonts.nunito(
                                  color: appColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                    ],
                  ),
                  
                  floatingActionButton: Row(
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children: [
                      FloatingActionButton.extended(
                        mouseCursor: SystemMouseCursors.click,
                        heroTag: "Add plugins", 
                        onPressed: () {
                          showDialog(
                            context: context, 
                            builder: (_) => InstallPluginDialog(
                              source: args.source,
                              onChange: initSelectPlugin,
                            )
                          );
                        },
                        backgroundColor: appColors.accentSecondary,
                        icon: Icon(
                          Icons.add,
                          color: appColors.textPrimary,
                        ),
                        label: Text(
                          "Add plugins",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight(700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              
            )
          ],
        )
      )
    );
  }
}