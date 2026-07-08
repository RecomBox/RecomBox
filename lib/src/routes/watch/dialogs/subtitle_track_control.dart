import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/routes/watch/dialogs/external_subtitles.dart';
import 'dart:math';

import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/subtitle_provider/get_installed_subtitles.dart';
import 'package:recombox/src/rust/method/subtitle_provider/remove_subtitles.dart';
class SubtitleTrackControlDialog extends StatefulWidget {
  const SubtitleTrackControlDialog({
    super.key,
    required this.watchScreenArgs,
    required this.player,
  });

  final WatchScreenArguments watchScreenArgs;
  final Player player;
  

  @override
  State<SubtitleTrackControlDialog> createState() => _SubtitleTrackControlDialogState();
}

class _SubtitleTrackControlDialogState extends State<SubtitleTrackControlDialog> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<SubtitleTrack> subtitleTrackList = [];
  Map<BigInt, GetInstalledSubtitlesData> externalSubtitleMap = {};

  @override
  void initState() {
    subtitleTrackList = widget.player.state.tracks.subtitle
      .where((track) => track.id != 'auto' && track.id != 'no' && track.codec != null)
      .toList();
      
    subtitleTrackList.insert(0, SubtitleTrack.no());
    super.initState();

    initWidget();
  }

  Future<void> initWidget() async {
    var installedSubtitle = await getInstalledSubtitles(
      source: widget.watchScreenArgs.source.name, 
      id: widget.watchScreenArgs.viewID, 
      seasonIndex: widget.watchScreenArgs.season, 
      episodeIndex: widget.watchScreenArgs.episode
    );

    if (context.mounted){
      setState(() {
        externalSubtitleMap = installedSubtitle;
      });
    }

  }

  void onSubtitleTrackChange(SubtitleTrack track){
    if (context.mounted){
      widget.player.setSubtitleTrack(track);
    }
  }

  void onDisableSubtitle(){
    if (context.mounted){
      widget.player.setSubtitleTrack(SubtitleTrack.no());
    }
  }

  void onClose(){
    if (context.mounted){
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600)
            Expanded(
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  color: Colors.black.withAlpha(130),
                ),
              )
            ),
          Container(
            width: min(600, MediaQuery.of(context).size.width),
            decoration: BoxDecoration(
              color: appColors.primary,
              border: Border(
                left: MediaQuery.of(context).size.width >= 600 
                  ? BorderSide(
                    width: 1,
                    color: appColors.strokePrimary
                  )
                  : BorderSide.none
              )
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: appColors.strokePrimary
                      )
                    )
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        iconSize: 32,
                        color: appColors.secondary,
                        onPressed: onClose,
                        icon: const Icon(Icons.close)
                      ),
                      Expanded(
                        child: Text(
                          "Subtitle Tracks",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight(600),
                          )
                        )
                      ),
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        iconSize: 32,
                        color: appColors.secondary,
                        onPressed: (){
                          if (context.mounted){
                            showDialog(
                              context: context, 
                              builder: (_)=>ExternalSubtitleDialog(
                                watchScreenArgs: widget.watchScreenArgs,
                                onClose: initWidget
                              )
                            );
                          }
                        },
                        icon: const Icon(Icons.add_circle_rounded)
                      ),
                    ],
                  )
                ),
                if (subtitleTrackList.isNotEmpty || externalSubtitleMap.isNotEmpty) ...[
                  ListView.separated(
                    shrinkWrap: true,
                    
                    itemCount: subtitleTrackList.length,
                    itemBuilder: (context, index) {
                      return 
                        InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          onTap: (){
                            onSubtitleTrackChange(subtitleTrackList[index]);
                            onClose();
                          },
                          child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              index > 0 
                                ?"Subtitle: ${subtitleTrackList[index].id} | ${subtitleTrackList[index].language ?? 'Default'}"
                                : "Disable",
                              style: GoogleFonts.nunito(
                                color: appColors.textPrimary,
                                fontSize: 18
                              ),
                              textAlign: TextAlign.start,
                            ),
                          )
                      );
                    
                      
                    }, 
                    separatorBuilder: (_,__) {
                      return Container(
                        height: 2,
                        color: appColors.strokePrimary,
                      );
                    }, 

                  ),
                  
                  // -> External Subtitles
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      
                      itemCount: externalSubtitleMap.length,
                      itemBuilder: (context, index) {
                        return 
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  mouseCursor: SystemMouseCursors.click,
                                  onTap: (){
                                    var sub = externalSubtitleMap[externalSubtitleMap.keys.toList()[index]];
                                    widget.player.setSubtitleTrack(
                                      SubtitleTrack.uri(sub!.path),
                                    );

                                    onClose();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.all(10),
                                    child: Text(externalSubtitleMap[externalSubtitleMap.keys.toList()[index]]!.title,
                                      style: GoogleFonts.nunito(
                                        color: appColors.textPrimary,
                                        fontSize: 18
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  )
                                ),
                              ),
                              
                              IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                iconSize: 32,
                                color: Colors.red,
                                onPressed: () async {
                                  try{
                                    await removeSubtitles(
                                      source: widget.watchScreenArgs.source.name,
                                      id: widget.watchScreenArgs.viewID, 
                                      seasonIndex: widget.watchScreenArgs.season, 
                                      episodeIndex: widget.watchScreenArgs.episode, 
                                      subtitleId: externalSubtitleMap.keys.toList()[index]
                                    );
                                  
                                    if (context.mounted){
                                      setState(() {
                                        externalSubtitleMap.remove(externalSubtitleMap.keys.toList()[index]);
                                      });
                                    }
                                  }catch(e){
                                    debugPrint(e.toString());
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline)
                              )
                            ],
                          );
                          
                      
                        
                      }, 
                      separatorBuilder: (_,__) {
                        return Container(
                          height: 2,
                          color: appColors.strokePrimary,
                        );
                      }, 

                    ),
                  ),
                
                  // <-
                ],

                if (subtitleTrackList.isEmpty && externalSubtitleMap.isEmpty)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "No subtitle track found",
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 18
                        ),
                        textAlign: TextAlign.start,
                      ),
                    )
                  )
                

              ],
            )
          
          )
        ]
      )
    );
  }
}