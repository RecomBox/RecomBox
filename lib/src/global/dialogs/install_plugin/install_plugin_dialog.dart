import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/widgets/install_plugin_tile.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/plugin_provider.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';
import 'dart:math';

import 'package:recombox/src/rust/method/plugin_provider/get_plugin_list.dart';
import 'package:recombox/src/rust/method/plugin_provider/install_plugin.dart';



class InstallPluginDialog extends StatefulWidget {
  const InstallPluginDialog({
    super.key,
    required this.source,
    this.onChange,
  });

  final VoidCallback? onChange;
  final Source source;

  @override
  State<InstallPluginDialog> createState() => _InstallPluginDialogState();
}

class _InstallPluginDialogState extends State<InstallPluginDialog> {

  AppColorsScheme appColors = appColorsNotifier.value;
  
  final TextEditingController _textEditingController = TextEditingController(text: '');
  FocusNode searchFocus = FocusNode();

  List<PluginInfo> pluginList = []; 
  Map<String, InstalledPluginInfo> installedPluginMap = {}; 


  bool isLoading = false;
  bool isInstalling = false;

  @override
  void initState() {
    super.initState();
    
    initDialog();
  }

  Future<void> initDialog({bool forceReload=true}) async {
    if (forceReload){
      setState(() {
        isLoading = true;
      });
    }
      
    try{
      List<PluginInfo> getPluginListResult = await getPluginList(source: widget.source.name);
      
      Map<String, InstalledPluginInfo> installedPluginMapResult = await getInstalledPlugins(source: widget.source.name);

      setState(() {
        pluginList = getPluginListResult;
        installedPluginMap = installedPluginMapResult;
      });

      debugPrint(getPluginListResult.toString());
      debugPrint(installedPluginMapResult.toString());
    }catch(e){
      debugPrint(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  bool isAllowInstall() {
    return isInstalling 
      ? false
      : true;

  }

  void onStartInstall() {
    setState(() {
      isInstalling = true;
    });
  }

  Future<void> onChange() async {
    await initDialog(forceReload: false);
    widget.onChange?.call();
    setState(() {
      isInstalling = false;
    });
    debugPrint("Success change");
  }

  List<PluginInfo> onFilterSearch() {
    return pluginList.where((element) => 
      element.pluginName.toLowerCase().contains(_textEditingController.text.toLowerCase())
      || element.pluginId.toLowerCase().contains(_textEditingController.text.toLowerCase())
      || element.manifestRepoName.toLowerCase().contains(_textEditingController.text.toLowerCase())
      || element.pluginRepoUrl.toLowerCase().contains(_textEditingController.text.toLowerCase())
    ).toList();
  }


  @override
  Widget build(BuildContext context) {
    
    List<PluginInfo> filteredPluginList = onFilterSearch();

    return Dialog(
      backgroundColor: appColors.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: min(500, MediaQuery.of(context).size.width * 0.9),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                child: Text(
                  'Install plugin',
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight(600),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              
              if (isLoading) 
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: appColors.secondary,
                      
                      ),
                    ),
                ),

              if (!isLoading) ...[
                if (pluginList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No categories found",
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                if (pluginList.isNotEmpty) ...[
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
                                    setState(() {
                                      filteredPluginList = onFilterSearch();
                                    });
                                  },
                                  onSubmitted: (value){
                                    setState(() {
                                      filteredPluginList = onFilterSearch();
                                    });
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

                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredPluginList.length,
                      itemBuilder: (context, index) {
                        return InstallPluginTile(
                          key: ValueKey(filteredPluginList[index].pluginId),
                          source: widget.source,
                          isInstalled: installedPluginMap[filteredPluginList[index].pluginId] != null,
                          onChange: onChange,
                          onStartInstall: onStartInstall,
                          isAllowInstall: isAllowInstall,
                          pluginInfo: filteredPluginList[index],
                        );
                      },
                    ),
                  ),
                ],
              
                
              ],

              Container(
                padding: EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      
                      onPressed: (){
                        
                      },
                      style: ElevatedButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                        backgroundColor: appColors.secondary,
                        foregroundColor: appColors.primary,
                      ),
                      icon: Icon(Icons.edit),
                      label: Text(
                        "Edit Repo",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight(600),
                        ),
                      ),
                      
                    ),

                    TextButton(
                      
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                      ),
                      child: Text(
                        "Done",
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight(600),
                        ),
                      
                      ),
                    ),
                    
                  ],
                ),
              )

            
            ],
          ),
        )
      ),
    );
  }
}
