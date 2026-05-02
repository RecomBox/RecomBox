import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/helpers/format_bytes.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_all_download.dart';
import 'package:recombox/src/rust/method/download_provider/get_download_status.dart';
import 'package:recombox/src/rust/method/download_provider/set_download_status.dart';
import 'dart:async';

class DownloadTile extends StatefulWidget {
  const DownloadTile({
    super.key,
    required this.index,
    required this.allDownloadItemKey,
    required this.allDownloadItemValue,
    required this.onRemoveDownload,
  });

  final int index;
  final AllDownloadItemKey allDownloadItemKey;
  final AllDownloadItemValue allDownloadItemValue;
  final VoidCallback onRemoveDownload;


  @override
  State<DownloadTile> createState() => _DownloadTileState();
}

class _DownloadTileState extends State<DownloadTile> {

  
  AppColorsScheme appColors = appColorsNotifier.value;
  
  DownloadStatus downloadStatusResult = DownloadStatus(
    progressSize: BigInt.from(0), 
    totalSize: BigInt.from(1), 
    paused: false, 
    done: false
  );

  Timer? _timer;


  @override
  void initState() {
    super.initState();
    initDownloadTile();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (context.mounted) {
        initDownloadTile();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initDownloadTile() async {
    try{
      var result = await getDownloadStatus(downloadItemKey: DownloadItemKey(
        source: widget.allDownloadItemKey.source, 
        id: widget.allDownloadItemKey.id, 
        seasonIndex: widget.allDownloadItemValue.seasonIndex, 
        episodeIndex: widget.allDownloadItemValue.episodeIndex
      ));
      

      if (result != null){

        setState(() {
          downloadStatusResult = result;
        });
      }
    }catch(e){
      debugPrint(e.toString());
    }


  }

  void onNavigate(){

  }

  Future<void> onChangePause() async {
    try{
      setState(() {
        downloadStatusResult = downloadStatusResult.copyWith(
          paused: !downloadStatusResult.paused,
        );
      });
      await setDownloadStatus(
        downloadItemKey: DownloadItemKey(
          source: widget.allDownloadItemKey.source, 
          id: widget.allDownloadItemKey.id, 
          seasonIndex: widget.allDownloadItemValue.seasonIndex, 
          episodeIndex: widget.allDownloadItemValue.episodeIndex,
        ), 
        downloadStatus: downloadStatusResult,
        applyProgress: false,
      );
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  
                  constraints: BoxConstraints(maxWidth: 100),
                  child: Text(
                    SourceExtension.fromString(widget.allDownloadItemKey.source) == Source.movies ? "Full" : "S${(widget.allDownloadItemValue.seasonIndex + BigInt.from(1)).toString().padLeft(2, '0')}E${(widget.allDownloadItemValue.episodeIndex + BigInt.from(1)).toString().padLeft(2, '0')}",
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 18
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                


                Text(
                  "${((downloadStatusResult.progressSize/downloadStatusResult.totalSize).toDouble() * 100).toStringAsFixed(2)}% | ${formatBytes(downloadStatusResult.totalSize)}",
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 18
                  )
                ),

              ],
              
            ),

            Row(
              spacing: 8,
              children: [

                if (downloadStatusResult.done)
                  Icon(
                    Icons.download_done_rounded,
                    size: 32,
                    color: appColors.secondary,
                  ),
                  

                if (!downloadStatusResult.done)
                  IconButton(
                    mouseCursor: SystemMouseCursors.click,
                    onPressed: onChangePause, 
                    icon: Icon(
                      downloadStatusResult.paused ? Icons.play_arrow : Icons.pause
                    ),
                    color: downloadStatusResult.paused ? Color(0xFF00FFFF): appColors.secondary,
                  ),

                

                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    width: double.infinity,
                    height: 5,
                    child: LinearProgressIndicator(
                      value: downloadStatusResult.progressSize.toDouble() / downloadStatusResult.totalSize.toDouble(),
                      color: appColors.accentSecondary,
                    ),
                  )
                ),

                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: widget.onRemoveDownload, 
                  icon: Icon(Icons.delete_forever),
                  color: Colors.red,
                ),
                
              ],
              
            ),
          ],
        )
      )
    );
  }
}