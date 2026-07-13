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
    required this.viewID,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
    required this.season,
    required this.episode,
    required this.episodeInfo,
    required this.onNavigateDownload,

    required this.bulkDownloadMode,
    required this.bulkDownloadSelectAll,
  });

  final Source source;
  final String viewID;
  final ExternalID externalID;
  final String title;
  final String titleSecondary;
  final BigInt season;
  final BigInt episode;
  final EpisodeInfo episodeInfo;
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
        height: 100,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: (){
                  navigateWatch(NavigateWatchArgs(
                    context: context, 
                    source: widget.source, 
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
                    Stack(
                      children: [
                        Ink.image(
                          width: 150,
                          height: 100,
                          image: failLoadThumbnail
                            ? const AssetImage('assets/episode_thumbnail_placeholder.jpg')
                            : NetworkImage(widget.episodeInfo.thumbnailUrl),
                          fit: BoxFit.cover,
                          onImageError: (_,__){
                            setState(() {
                              failLoadThumbnail = true;
                            });
                          },
                        ),

                        if (watchPosition > BigInt.from(0))
                          Container(
                            width: 150,
                            height: 100,
                            padding: EdgeInsets.all(2.5),
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              Duration(milliseconds: watchPosition.toInt()).toString().split('.').first.padLeft(8, "0"),
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                backgroundColor: Colors.black.withAlpha(125)
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            )
                          )
                      ],
                    ),
                    
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.episodeInfo.title,
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
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