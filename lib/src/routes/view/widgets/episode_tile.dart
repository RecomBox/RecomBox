import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/bulk_download.dart';
import 'package:recombox/src/global/navigate_watch.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_download.dart';
import 'package:recombox/src/rust/method/download_provider/get_download_status.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'package:recombox/src/rust/method/watch_state.dart';
import 'package:recombox/src/rust/method/watch_state/get_watch_state.dart';

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({
    super.key,
    required this.source,
    required this.provider,
    required this.viewID,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
    required this.season,
    required this.episode,
    required this.onNavigateDownload,

    required this.bulkDownloadMode,
    required this.bulkDownloadSelectAll,
  });

  final Source source;
  final int? provider;
  final String viewID;
  final ExternalID externalID;
  final String title;
  final String titleSecondary;
  final BigInt season;
  final BigInt episode;
  final Function() onNavigateDownload;


  final bool bulkDownloadMode;
  final bool bulkDownloadSelectAll;




  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool failLoadThumbnail = false;
  bool isInDownload = false;
  bool selectForBulkDownload = false;
  DownloadStatus downloadStatusResult = DownloadStatus(
    progressSize: BigInt.from(0), 
    totalSize: BigInt.from(0), 
    paused: false, 
    done: false
  );
  BigInt watchPosition = BigInt.from(0);

  @override
  void initState() {
    super.initState();

    initEpisode();
  }

  Future<void> initEpisode() async {
    try{
      DownloadItemValue? downloadItemValue = await getDownload(downloadItemKey: DownloadItemKey(
        source: widget.source.name, 
        id: widget.viewID, 
        seasonIndex:  widget.season, 
        episodeIndex: widget.episode
      ));

      var downloadStatus = await getDownloadStatus(downloadItemKey: DownloadItemKey(
        source: widget.source.name, 
        id: widget.viewID, 
        seasonIndex: widget.season,
        episodeIndex: widget.episode
      ));

      var watchState = await getWatchState(watchStateKey: WatchStateKey(
        source: widget.source.name, 
        id: widget.viewID, 
        seasonIndex: widget.season, 
        episodeIndex: widget.episode
      ));

      if (context.mounted){
        if (downloadItemValue != null){
          setState(() {
            isInDownload = true;
            
          });
        }
        if (downloadStatus != null){
          setState(() {
            downloadStatusResult = downloadStatus;
          });
        }

        if (watchState != null){
          setState(() {
            watchPosition = watchState.position ?? BigInt.from(0);
          });
        }
      }

      if (!isInDownload){
        if (context.mounted && widget.bulkDownloadMode && (bulkDownload.seasonIndex == widget.season)){
          setState(() {
            selectForBulkDownload = widget.bulkDownloadSelectAll || bulkDownload.contains(widget.episode);
          });
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: (){
                  navigateWatch(NavigateWatchArgs(
                    context: context, 
                    source: widget.source, 
                    provider: widget.provider,
                    viewID: widget.viewID, 
                    externalID: widget.externalID, 
                    title: widget.title, 
                    titleSecondary: widget.titleSecondary, 
                    seasonIndex: widget.season, 
                    episodeIndex: widget.episode
                  ));
                },
                mouseCursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left:10, right: 10, top: 25, bottom: 25),
                        child: Column(
                          spacing: 12,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Episode ${widget.episode.toInt()+1}",
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (watchPosition > BigInt.from(0))
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 5,
                                children: [
                                  Icon(
                                    Icons.visibility_rounded,
                                    color: appColors.textSecondary,
                                    size: 16,
                                  ),

                                  Text(
                                    Duration(milliseconds: watchPosition.toInt()).toString().split('.').first.padLeft(8, "0"),
                                    style: TextStyle(
                                      color: appColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 3,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              )
                              
                            
                          ],
                        )
                      )
                    ),
              
                  ],
                ),
              ),
            ),
            
            if (!isInDownload && !widget.bulkDownloadMode)
              IconButton(
                mouseCursor: SystemMouseCursors.click,
                onPressed: widget.onNavigateDownload,
                icon: Icon(
                  Icons.download_rounded,
                  color: appColors.secondary,
                  size: 32
                )
              ),
            if (isInDownload) ...[
              if (!downloadStatusResult.done)
                Container(
                  padding: EdgeInsets.all(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(appColors.secondary),
                        ),
                      ),
                      Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: appColors.secondary,
                      ),
                    ],
                  ),
                ),
              if (downloadStatusResult.done)
                Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.save_rounded,
                      size: 32,
                      color: appColors.secondary,
                    ),
                  ),
            ],

            if (!downloadStatusResult.done && !isInDownload && widget.bulkDownloadMode)
                Container(
                  padding: EdgeInsets.all(10),
                  child: Checkbox(
                      mouseCursor: SystemMouseCursors.click,
                      checkColor: appColors.primary,
                      activeColor: appColors.secondary,
                      
                      side: BorderSide(
                        color: appColors.strokePrimary, 
                        width: 2,
                      ),
                      value: selectForBulkDownload,
                      onChanged: (bool? value) {
                        if (value == null) return;
                        setState(() {
                          selectForBulkDownload = value;
                        });
                        if (value){
                          bulkDownload.add(widget.episode, BulkDownloadValue());
                        }else{
                          bulkDownload.remove(widget.episode);
                        }

                        debugPrint(bulkDownload.len().toString());
                      },
                    )
                )
          ],
        ),
      ),
    );
  }
}