import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:recombox/src/global/app_color.dart';
import 'dart:math';
class AudioTrackControlDialog extends StatefulWidget {
  const AudioTrackControlDialog({
    super.key,
    required this.player,
  });

  final Player player;
  

  @override
  State<AudioTrackControlDialog> createState() => _AudioTrackControlDialogState();
}

class _AudioTrackControlDialogState extends State<AudioTrackControlDialog> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<AudioTrack> audioTrackList = [];

  @override
  void initState() {
    super.initState();
    audioTrackList = widget.player.state.tracks.audio
      .where((track) => track.id != 'auto' && track.id != 'no' && track.codec != null)
      .toList();
  }

  void onAudioTrackChange(AudioTrack track){
    if (context.mounted){
      widget.player.setAudioTrack(track);
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
                          "Audio Tracks",
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
                if (audioTrackList.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      
                      itemCount: audioTrackList.length,
                      itemBuilder: (context, index) {
                        return 
                          InkWell(
                            mouseCursor: SystemMouseCursors.click,
                            onTap: (){
                              onAudioTrackChange(audioTrackList[index]);
                              onClose();
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Audio: ${audioTrackList[index].id} | ${audioTrackList[index].language ?? 'Default'}",
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
                  

                if (audioTrackList.isEmpty)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "No audio track found",
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