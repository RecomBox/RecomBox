import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/plugin_provider.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_sources.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_torrents.dart';
import 'package:recombox/src/rust/method/plugin_provider/install_plugin.dart';
import 'package:recombox/src/rust/method/plugin_provider/remove_plugin.dart';
import 'package:path/path.dart' as path;
import 'package:recombox/src/rust/method/torrent_provider/get_torrent_metadata.dart';

class SelectFileTile extends StatefulWidget {
  const SelectFileTile({
    super.key,
    required this.source,
    required this.viewID,
    required this.torrentSource,
    required this.fileInfo,
    required this.season,
    required this.episode,
  }); 

  final Source source;
  final String viewID;
  final String torrentSource;
  final FileInfo fileInfo;
  final BigInt season;
  final BigInt episode;



  @override
  State<SelectFileTile> createState() => _SelectFileTileState();
}

class _SelectFileTileState extends State<SelectFileTile> {

  AppColorsScheme appColors = appColorsNotifier.value;

  @override
  void initState() {
    super.initState();
    
  }

  void onNavigate() {
    final mimeType = lookupMimeType(widget.fileInfo.path??"")??"application/octet-stream";

    WatchScreenArguments watchScreenArgs = WatchScreenArguments(
      viewID: widget.viewID,
      source: widget.source,
      mimeType: mimeType,
      torrentSource: widget.torrentSource,
      fileID: widget.fileInfo.id,
      season: widget.season,
      episode: widget.episode
    );

    Navigator.pushNamed(
      context,
      '/watch',
      arguments: watchScreenArgs,
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onNavigate,
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.basename(widget.fileInfo.path ?? ""),
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 24
                        ),
                      ),
                    ],
                  )
                  
                )
              ),
            ]
          )
        )
      )
    );
  
  }
}