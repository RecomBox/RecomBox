import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/rust/method/plugin_provider.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_sources.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_torrents.dart';
import 'package:recombox/src/rust/method/plugin_provider/install_plugin.dart';
import 'package:recombox/src/rust/method/plugin_provider/remove_plugin.dart';

class SelectTorrentTile extends StatefulWidget {
  const SelectTorrentTile({
    super.key,
    required this.viewID,
    required this.source,
    required this.torrentInfo,
    required this.season,
    required this.episode

  }); 

  final String viewID;
  final Source source;
  final TorrentInfo torrentInfo;
  final BigInt season;
  final BigInt episode;



  @override
  State<SelectTorrentTile> createState() => _SelectTorrentTileState();
}

class _SelectTorrentTileState extends State<SelectTorrentTile> {

  AppColorsScheme appColors = appColorsNotifier.value;

  @override
  void initState() {
    super.initState();
    
  }

  void onNavigate() {
    Navigator.pushNamed(
      context, 
      "/select_file",
      arguments: SelectFileScreenArguments(
        viewID: widget.viewID, 
        source: widget.source,
        torrentSource: widget.torrentInfo.torrentUrl,
        season: widget.season,
        episode: widget.episode

      )
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
                        widget.torrentInfo.title,
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