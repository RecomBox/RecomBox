import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/set_download.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/favorite/set_last_watch_torrent.dart';
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
    required this.selectFileMode,
    required this.source,
    required this.viewID,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
    required this.torrentSource,
    required this.fileInfo,
    required this.season,
    required this.episode,
  }); 

  final SelectFileMode selectFileMode;
  final Source source;
  final String viewID;
  final String externalID;
  final String title;
  final String titleSecondary;
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

  Future<void> onSelectFile() async {
    final ctx = context;
    final mimeType = lookupMimeType(widget.fileInfo.path??"")??"application/octet-stream";
    if (widget.selectFileMode == SelectFileMode.watch){
      try{
        await setLastWatchTorrent(
          source: widget.source.name, 
          id: widget.viewID, 
          seasonIndex: widget.season, 
          episodeIndex: widget.episode, 
          lastWatchTorrentInfo: LastWatchTorrentInfo(
            torrentSource: widget.torrentSource, 
            mimeType: mimeType,
            fileId: widget.fileInfo.id
          )
        );
      }catch(e){
        debugPrint(e.toString());
      }

      WatchScreenArguments watchScreenArgs = WatchScreenArguments(
        selectFileMode: widget.selectFileMode,
        viewID: widget.viewID,
        source: widget.source,
        externalID: widget.externalID,
        title: widget.title,
        titleSecondary: widget.titleSecondary,
        mimeType: mimeType,
        torrentSource: widget.torrentSource,
        fileID: widget.fileInfo.id,
        season: widget.season,
        episode: widget.episode
      );

      if (ctx.mounted){
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          '/watch',
          (route) => false,
          arguments: watchScreenArgs,
        );
      }
    }else if (widget.selectFileMode == SelectFileMode.download){
      try{
        await setDownload(
          downloadItemKey: DownloadItemKey(
            source: widget.source.name, 
            id: widget.viewID, 
            seasonIndex: widget.season, 
            episodeIndex: widget.episode
          ), 
          downloadItemValue: DownloadItemValue(
            torrentSource: widget.torrentSource, 
            fileId: widget.fileInfo.id, 
            filePath: "",
            mimeType: mimeType,
          )
        );

        ViewScreenArguments viewScreenArguments = ViewScreenArguments(
          source: widget.source, 
          id: widget.viewID
        );

        if (ctx.mounted){
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          '/view',
          (route) => false,
          arguments: viewScreenArguments,
        );
      }
      }catch(e){
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onSelectFile,
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