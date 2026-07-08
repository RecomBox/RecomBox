import 'package:flutter/material.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_download.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/favorite/get_last_watch_torrent.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

class NavigateWatchArgs {
  final BuildContext context;
  final Source source;
  final String viewID;
  final ExternalID externalID;
  final String title;
  final String titleSecondary;
  final BigInt seasonIndex;
  final BigInt episodeIndex;

  const NavigateWatchArgs({
    required this.context,
    required this.source,
    required this.viewID,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
    required this.seasonIndex,
    required this.episodeIndex,
  });
}

Future<void> navigateWatch(NavigateWatchArgs args) async{
  final ctx = args.context;
  // -> Get downloaded
  try{
    final downloadInfo = await getDownload(downloadItemKey: DownloadItemKey(
      source: args.source.name, 
      id: args.viewID, 
      seasonIndex: args.seasonIndex, 
      episodeIndex: args.episodeIndex
    ));

    if (downloadInfo != null){
      WatchScreenArguments watchScreenArgs = WatchScreenArguments(
        selectFileMode: SelectFileMode.watch,
        source: args.source, 
        viewID: args.viewID, 
        externalID: args.externalID, 
        title: args.title, 
        titleSecondary: args.titleSecondary, 
        torrentSource: downloadInfo.torrentSource, 
        mimeType: downloadInfo.mimeType, 
        fileID: downloadInfo.fileId, 
        season: args.seasonIndex,
        episode: args.episodeIndex
      );
      if (ctx.mounted){
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          '/watch',
          (route) => false,
          arguments: watchScreenArgs,
        );
      }
      return;
    }
  }catch(e){
    debugPrint(e.toString());
  }
  // <-

  try{
    LastWatchTorrentInfo? lastWatchTorrentInfo = await getLastWatchTorrent(
      source: args.source.name, 
      id: args.viewID, 
      seasonIndex: args.seasonIndex, 
      episodeIndex: args.episodeIndex
    );
    debugPrint(lastWatchTorrentInfo.toString());
    if (lastWatchTorrentInfo != null){
      WatchScreenArguments watchScreenArgs = WatchScreenArguments(
        selectFileMode: SelectFileMode.watch,
        source: args.source, 
        viewID: args.viewID, 
        externalID: args.externalID, 
        title: args.title, 
        titleSecondary: args.titleSecondary, 
        torrentSource: lastWatchTorrentInfo.torrentSource, 
        mimeType: lastWatchTorrentInfo.mimeType, 
        fileID: lastWatchTorrentInfo.fileId, 
        season: args.seasonIndex,
        episode: args.episodeIndex
      );
      if (ctx.mounted){
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          '/watch',
          (route) => false,
          arguments: watchScreenArgs,
        );
      }
      return;
    }
  }catch(e){
    debugPrint(e.toString());
  }
  
  SelectPluginScreenArguments selectPluginArgs = SelectPluginScreenArguments(
    selectFileMode:  SelectFileMode.watch,
    source: args.source,
    id: args.viewID,
    externalID: args.externalID,
    title: args.title,
    titleSecondary: args.titleSecondary,
    season: args.seasonIndex,
    episode: args.episodeIndex
  );

  if (ctx.mounted){
    Navigator.pushNamed(
      ctx,
      '/select_plugin',
      arguments: selectPluginArgs,
    );
  }

}