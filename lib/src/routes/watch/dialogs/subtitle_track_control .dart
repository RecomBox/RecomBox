import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:recombox/src/global/app_color.dart';
import 'dart:math';
class SubtitleTrackControlDialog extends StatefulWidget {
  const SubtitleTrackControlDialog({
    super.key,
    required this.player,
  });

  final Player player;
  

  @override
  State<SubtitleTrackControlDialog> createState() => _SubtitleTrackControlDialogState();
}

class _SubtitleTrackControlDialogState extends State<SubtitleTrackControlDialog> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<SubtitleTrack> subtitleTrackList = [];

  @override
  void initState() {
    subtitleTrackList = widget.player.state.tracks.subtitle
      .where((track) => track.id != 'auto' && track.id != 'no' && track.codec != null)
      .toList();
      
    subtitleTrackList.insert(0, SubtitleTrack.no());
    super.initState();

  }

  void onSubtitleTrackChange(SubtitleTrack track){
    widget.player.setSubtitleTrack(track);
  }

  void onDisableSubtitle(){
    widget.player.setSubtitleTrack(SubtitleTrack.no());
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
                    ],
                  )
                ),
                if (subtitleTrackList.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
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
                  ),
                  

                if (subtitleTrackList.isEmpty)
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