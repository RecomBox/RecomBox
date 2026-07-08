import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_torrents.dart';

class SelectTorrentTile extends StatefulWidget {
  const SelectTorrentTile({
    super.key,
    required this.selectFileMode,
    required this.viewID,
    required this.source,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
    required this.torrentInfo,
    required this.season,
    required this.episode

  }); 

  final SelectFileMode selectFileMode;
  final String viewID;
  final Source source;
  final ExternalID externalID;
  final String title;
  final String titleSecondary;
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
        selectFileMode: widget.selectFileMode,
        viewID: widget.viewID, 
        source: widget.source,
        externalID: widget.externalID,
        title: widget.title,
        titleSecondary: widget.titleSecondary,
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