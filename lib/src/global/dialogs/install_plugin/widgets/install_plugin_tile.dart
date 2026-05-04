import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/plugin_provider.dart';
import 'package:recombox/src/rust/method/plugin_provider/install_plugin.dart';
import 'package:recombox/src/rust/method/plugin_provider/remove_plugin.dart';

class InstallPluginTile extends StatefulWidget {
  const InstallPluginTile({
    super.key,
    required this.source,
    required this.isInstalled,
    this.installedVersion,
    required this.pluginInfo,
    this.isAllowInstall,
    this.onStartInstall,
    this.onChange

  });

  final Source source;
  final bool isInstalled;
  final String? installedVersion;
  final PluginInfo pluginInfo;
  final bool Function()? isAllowInstall;
  final VoidCallback? onStartInstall;
  final VoidCallback? onChange;


  @override
  State<InstallPluginTile> createState() => _SetFavoriteTileState();
}

class _SetFavoriteTileState extends State<InstallPluginTile> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool isInstalled = false;
  bool isInstalling = false;
  bool isUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
    
    isInstalled = widget.isInstalled;
    // if (isInstalled){
    //   // TODO: Implement plugin update
    //   var installedVersion = Version.parse(widget.installedVersion ?? "0.0.0");
    // }
  }

  Future<void> onInstallPlugin() async {
    if (!(widget.isAllowInstall?.call() ?? false)) return;

    setState(() {
      isInstalling = true;
    });

    widget.onStartInstall?.call();
    try{
      await installPlugin(
        source: widget.source.name, 
        pluginInfo: widget.pluginInfo
      );
    }catch(e){
      debugPrint(e.toString());
      setState(() {
        isInstalling = false;
      });
      widget.onChange?.call();
      return;
    }

    setState(() {
      isInstalled = true;
      isInstalling = false;
    });

    widget.onChange?.call();
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
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Image failed: $error');
                return const SizedBox(); 
              },
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
                  onPressed: onInstallPlugin,
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