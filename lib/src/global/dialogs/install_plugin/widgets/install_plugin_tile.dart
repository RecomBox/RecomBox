import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/plugin_provider.dart';
import 'package:recombox/src/rust/method/plugin_provider/remove_plugin.dart';

class InstallPluginTile extends StatefulWidget {
  const InstallPluginTile({
    super.key,
    required this.source,
    required this.isInstalled,
    required this.pluginInfo,
    required this.onInstallPlugin,
    this.onChange

  });

  final Source source;
  final bool isInstalled;
  final PluginInfo pluginInfo;
  final Future<void> Function(OnInstallPluginArgs) onInstallPlugin;
  final VoidCallback? onChange;


  @override
  State<InstallPluginTile> createState() => _SetFavoriteTileState();
}

class _SetFavoriteTileState extends State<InstallPluginTile> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool isInstalled = false;
  bool isInstalling = false;

  @override
  void initState() {
    super.initState();
    
    isInstalled = widget.isInstalled;
  }

  Future<void> onRemovePlugin() async {
    try{
      await removePlugins(
        source: widget.source.name,
        pluginInfo: widget.pluginInfo 
      );
      setState(() {
        isInstalled = false;
      });
      widget.onChange?.call();
    }catch(e){
      debugPrint(e.toString());
      return;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        child: Row(
          children: [
            Image.network(
              widget.pluginInfo.pluginIconUrl,
              width: 50,

            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pluginInfo.pluginName,
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 24
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "From: ${widget.pluginInfo.manifestRepoName}",
                      style: GoogleFonts.nunito(
                        color: appColors.textSecondary,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
                
              )
            ),

            if (!isInstalled) ...[
              if (isInstalling)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: appColors.secondary,
                  
                  ),
                ),
                  
              if (!isInstalling)
                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: (){
                    widget.onInstallPlugin(
                      OnInstallPluginArgs(
                        pluginInfo: widget.pluginInfo,
                        onStart: () {
                          setState(() {
                            isInstalling = true;
                          });
                        },
                        onFail: (){
                          setState(() {
                            isInstalling = false;
                          });
                        },
                        onComplete: (){
                          setState(() {
                            isInstalling = false;
                            isInstalled = true;
                          });
                        }
                      )
                    );
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    color: appColors.secondary,
                    size: 32,
                  ),
                ),
            ],
            if (isInstalled)
              IconButton(
                mouseCursor: SystemMouseCursors.click,
                onPressed: (){
                  onRemovePlugin();
                },
                icon: Icon(
                  Icons.delete_rounded,
                  color: appColors.secondary,
                  size: 32,
                ),
              )
          ],
        )
      )
    
    );
  
  }
}