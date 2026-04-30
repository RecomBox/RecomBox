import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_all_download.dart';
import 'package:recombox/src/rust/method/download_provider/get_download.dart';
import 'package:recombox/src/rust/method/download_provider/get_download_status.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({
    super.key,
    required this.source,
    required this.viewID,
    required this.season,
    required this.episode,
    required this.episodeInfo,
    required this.onNavigateWatch,
    required this.onNavigateDownload
  });

  final Source source;
  final String viewID;
  final BigInt season;
  final BigInt episode;
  final EpisodeInfo episodeInfo;

  final Function() onNavigateWatch;
  final Function() onNavigateDownload;


  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool failLoadThumbnail = false;
  bool isInDownload = false;
  DownloadStatus downloadStatusResult = DownloadStatus(
    progressSize: BigInt.from(0), 
    totalSize: BigInt.from(0), 
    paused: false, 
    done: false
  );

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
      }
    }catch(e){
      debugPrint(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onNavigateWatch,
        mouseCursor: SystemMouseCursors.click,
        child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
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
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        )
                      ],
                    )
                  )
                ),
                // Container(
                //   alignment: Alignment.center,
                //   padding: EdgeInsets.only(right: 5, left: 5),
                //   child: Icon(
                //     Icons.save_rounded,
                //     color: appColors.secondary,
                //   )
                // )
                if (!isInDownload)
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
                      )
                ]
              ],
            ),
          ),
        )
      );
  }
}