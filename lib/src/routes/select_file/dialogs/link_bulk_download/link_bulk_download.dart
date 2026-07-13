import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/bulk_download.dart';
import 'package:recombox/src/global/types.dart';
import 'dart:math';

import 'package:recombox/src/rust/method/torrent_provider/get_torrent_metadata.dart';



class LinkBulkDownload extends StatefulWidget {
  const LinkBulkDownload({
    super.key,
    required this.source,
    required this.id,
    required this.seasonIndex,
    required this.fileInfo,
    required this.torrentSource,
  });

  final Source source;
  final String id;
  final BigInt seasonIndex;
  final FileInfo fileInfo;
  final String torrentSource;

  @override
  State<LinkBulkDownload> createState() => _LinkBulkDownloadState();
}

class _LinkBulkDownloadState extends State<LinkBulkDownload> {

  AppColorsScheme appColors = appColorsNotifier.value;
  
  Map<BigInt, BulkDownloadValue> bulkDownloadMap = {};
    

  // final TextEditingController _textEditingController = TextEditingController(text: '');
  // FocusNode searchFocus = FocusNode();


  bool isLoading = false;
  bool hideSelected = true;

  @override
  void initState() {
    super.initState();
    
    initDialog();
  }

  Future<void> initDialog() async {
    setState(() {
      isLoading = true;
    });
    

    try{
      var result = bulkDownload.get();
      result = Map.fromEntries(result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      if (hideSelected) {
        result = Map.fromEntries(
          result.entries.where((entry) => (entry.value.linkedFileID == null) && (entry.value.linkedFileName == null) && (entry.value.linkedTorrentUrl == null) && (entry.value.linkedMimeType == null))
        );
      }
      
      setState(() {
        bulkDownloadMap = result;
      });
    
    }catch(e){
      debugPrint(e.toString());
    }

    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> linkBulkDownload(BigInt episodeIndex) async {
    var bulkdownloadValue = bulkDownloadMap[episodeIndex];
    final mimeType = lookupMimeType(widget.fileInfo.path??"")??"application/octet-stream";

    if (bulkdownloadValue != null){
      bulkdownloadValue.linkedFileID = widget.fileInfo.id;
      bulkdownloadValue.linkedFileName = widget.fileInfo.path;
      bulkdownloadValue.linkedTorrentUrl = widget.torrentSource;
      bulkdownloadValue.linkedMimeType = mimeType;
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return Dialog(
      backgroundColor: appColors.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: min(500, MediaQuery.of(context).size.width * 0.9),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: appColors.textPrimary,
                      size: 32,
                    ),
                    Expanded(
                      child: Text(
                          'Select item to link',
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight(600),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: appColors.strokePrimary,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Text(
                          'Filename: ${widget.fileInfo.path}',
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight(600),
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (isLoading) 
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: appColors.secondary,
                      
                      ),
                    ),
                ),

              if (!isLoading) ...[
                if (bulkDownloadMap.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No item to link",
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                if (bulkDownloadMap.isNotEmpty) ...[
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: bulkDownloadMap.keys.length,
                      itemBuilder: (context, index) {

                        bool isLinked = (bulkDownloadMap[bulkDownloadMap.keys.toList()[index]]?.linkedFileID != null) 
                          && (bulkDownloadMap[bulkDownloadMap.keys.toList()[index]]?.linkedFileName != null) 
                          && (bulkDownloadMap[bulkDownloadMap.keys.toList()[index]]?.linkedTorrentUrl != null) 
                          && (bulkDownloadMap[bulkDownloadMap.keys.toList()[index]]?.linkedMimeType != null);
                        return InkWell(
                          onTap: (){
                            linkBulkDownload(bulkDownloadMap.keys.toList()[index]);
                            setState(() {
                              isLinked = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${bulkDownload.source == Source.anime ? "" : "S${((bulkDownload.seasonIndex??BigInt.from(0))+BigInt.from(1)).toString().padLeft(2, "0")}"}E${(bulkDownloadMap.keys.toList()[index]+BigInt.from(1)).toString().padLeft(2, "0")}", 
                                    style: GoogleFonts.nunito(
                                      color: appColors.textPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if (isLinked)
                                  Icon(
                                    Icons.checklist_rounded,
                                    color: appColors.secondary,
                                    size: 28,
                                  )
                              ],
                            )
                          )
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          height: 1,
                          color: appColors.strokePrimary,
                        );
                      },
                    )
                  ),
                ],
              
                
              ],

              Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 15,
                  children: [
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        setState(() {
                          hideSelected = !hideSelected;
                        });
                        initDialog();
                      },
                      child: Row(
                        children: [

                          Checkbox(
                            mouseCursor: SystemMouseCursors.click,
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return appColors.secondary;
                                }
                                return Colors.transparent;
                              },
                            ),
                            side: BorderSide(
                              color: appColors.secondary,
                              width: 2,
                            ),
                            
                            checkColor: appColors.primary,
                            value: hideSelected,
                            onChanged: (value) {
                              setState(() {
                                hideSelected = value!;
                              });
                              initDialog();
                            },
                          ),
                          Text(
                            'Hide selected',
                            style: GoogleFonts.nunito(
                              color: appColors.textPrimary,
                              fontSize: 16
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      )
                    
                    ),
                    
                      
                    
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                      ),
                      child: Text(
                        "Close",
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight(600),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              )

            
            ],
          ),
        )
      ),
    );
  }
}
