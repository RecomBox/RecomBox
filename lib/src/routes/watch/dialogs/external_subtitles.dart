import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'dart:math';

import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/subtitle_provider/get_chapters.dart';
import 'package:recombox/src/rust/method/subtitle_provider/get_subtitles.dart';
import 'package:recombox/src/rust/method/subtitle_provider/install_subtitle.dart';
import 'package:recombox/src/rust/method/subtitle_provider/search_subtitles.dart';
class ExternalSubtitleDialog extends StatefulWidget {
  const ExternalSubtitleDialog({
    super.key,
    required this.watchScreenArgs,
    required this.onClose,
  });

  final WatchScreenArguments watchScreenArgs;

  final Function onClose;
  

  @override
  State<ExternalSubtitleDialog> createState() => _ExternalSubtitleDialogState();
}

class _ExternalSubtitleDialogState extends State<ExternalSubtitleDialog> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<SubtitleTrack> subtitleTrackList = [];

  Map<String, List<SubtitleData>> subtitleDataMap = {};

  List<String> installedSubtitleList = [];
  List<String> installingSubtitleList = [];
  List<ChapterData> availableChaptersList = [];

  bool isLoading = true;
  bool isSelectChapter = false;
  String managedSearchLink = "";

  @override
  void initState() {
    super.initState();

    initExternalSubtitle();
  }

  Future<void> initExternalSubtitle() async {

    if (context.mounted){
      setState(() {
        isLoading = true;
      });
    }
    try{
      if (widget.watchScreenArgs.source == Source.movies || managedSearchLink.isNotEmpty){
        
        dynamic rawResult;

        if (widget.watchScreenArgs.source == Source.movies){
          var searchResult = await searchSubtitles(imdbId: widget.watchScreenArgs.externalID.imdb??"", source: widget.watchScreenArgs.source.name);

          rawResult = await getSubtitles(link: searchResult?.link ?? "");
        }else{
          rawResult = await getSubtitles(link: managedSearchLink);
        }

        Map<String, List<SubtitleData>> getSubtitlesResult = Map.from(
          SplayTreeMap<String, List<SubtitleData>>.from(rawResult)
        );


        if (context.mounted){
          setState(() {
            subtitleDataMap = getSubtitlesResult;
            isSelectChapter = false;
          });
        }

      }else{
        var getChaptersResult = await getChapters(
          imdbId: widget.watchScreenArgs.externalID.imdb??"", 
          source: widget.watchScreenArgs.source.name,
        );

        if (context.mounted){
          setState(() {
            availableChaptersList = getChaptersResult;
            isSelectChapter = true;
          });
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      if (context.mounted){
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void onClose(){
    if (context.mounted){
      Navigator.pop(context);
    }
    widget.onClose();
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
                          "External Subtitle",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight(600),
                          )
                        )
                      ),
                    ],
                  )
                ),

                if (!isLoading) ...[
                  if (!isSelectChapter) ...[
                    if (subtitleDataMap.isNotEmpty)
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          
                          itemCount: subtitleDataMap.keys.length,
                          itemBuilder: (context, index_1) {
                            return 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: appColors.strokePrimary
                                        )
                                      )
                                    ),
                                    child: Text(subtitleDataMap.keys.toList()[index_1],
                                      style: GoogleFonts.nunito(
                                        color: appColors.textPrimary,
                                        fontSize: 18
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  
                                  Container(
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      
                                      itemCount: subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]!.length,
                                      itemBuilder: (context, index_2) {
                                        

                                        return 
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]![index_2].title,
                                                    style: GoogleFonts.nunito(
                                                      color: appColors.textPrimary,
                                                      fontSize: 18
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                )
                                              ),
                                              
                                              if (!installingSubtitleList.contains(subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]![index_2].link)) ...[
                                                if (!installedSubtitleList.contains(subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]![index_2].link))
                                                  IconButton(
                                                    mouseCursor: SystemMouseCursors.click,
                                                    onPressed: () async {
                                                      var sub = subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]![index_2];
                                                      
                                                      if (installingSubtitleList.contains(sub.link)) return;

                                                      if (context.mounted){
                                                        setState(() {
                                                          installingSubtitleList.add(sub.link);
                                                        });
                                                      }
                                                      try{
                                                        await installSubtitle(
                                                          source: widget.watchScreenArgs.source.name, 
                                                          id: widget.watchScreenArgs.viewID, 
                                                          seasonIndex: widget.watchScreenArgs.season, 
                                                          episodeIndex: widget.watchScreenArgs.episode, 
                                                          language: subtitleDataMap.keys.toList()[index_1], 
                                                          link: sub.link
                                                        );

                                                        if (context.mounted){
                                                          setState(() {
                                                            installedSubtitleList.add(sub.link);
                                                          });
                                                        }
                                                      }catch(e){
                                                        debugPrint(e.toString());
                                                      }finally{
                                                        installingSubtitleList.remove(sub.link);
                                                      }
                                                    },
                                                    icon: Icon(Icons.add_circle_rounded, color: appColors.secondary, size: 24),
                                                  ),
                                                
                                                if (installedSubtitleList.contains(subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]![index_2].link))
                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Icon(Icons.check_circle_rounded, color: Colors.green),
                                                  )
                                              ],

                                              if (installingSubtitleList.contains(subtitleDataMap[subtitleDataMap.keys.toList()[index_1]]![index_2].link)) ...[
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    color: appColors.secondary,
                                                  
                                                  ),
                                                ),
                                              ]
                                            ],
                                          );
                                          
                                      
                                        
                                      }, 
                                      separatorBuilder: (_,__) {
                                        return Container(
                                          height: 1,
                                          color: appColors.strokePrimary,
                                        );
                                      }, 

                                    ),
                                  )

                                  
                                  
                                ],
                              
                              );
                              
                              
                          }, 
                          separatorBuilder: (_,__) {
                            return Container();
                          }, 

                        ),
                      ),
                      
                    if (subtitleDataMap.isEmpty)
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

                  if (isSelectChapter) 
                    Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          
                          itemCount: availableChaptersList.length,
                          itemBuilder: (context, index) {
                            return 
                              InkWell(
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  if (context.mounted){
                                    setState(() {
                                      managedSearchLink = availableChaptersList[index].link;
                                      initExternalSubtitle();
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: appColors.strokePrimary
                                      )
                                    )
                                  ),
                                  child: Text(availableChaptersList[index].title,
                                    style: GoogleFonts.nunito(
                                      color: appColors.textPrimary,
                                      fontSize: 18
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                  
                              );
                              
                          }, 
                          separatorBuilder: (_,__) {
                            return Container();
                          }, 

                        ),
                      ),
                ],

                if (isLoading)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: appColors.secondary,
                        ),
                      )
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