import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/download/widgets/download_tile.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/method/download_provider/get_all_download.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'dart:io';
import 'dart:math';

class DownloadCard extends StatefulWidget {
  const DownloadCard({
    super.key,
    required this.allDownloadItemKey,
    required this.allDownloadItemValueList,
    required this.onRemoveDownload,
  });

  final AllDownloadItemKey allDownloadItemKey;
  final List<AllDownloadItemValue> allDownloadItemValueList;
  final void Function(AllDownloadItemKey key, int index) onRemoveDownload;

  @override
  State<DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<DownloadCard> {

  
  AppColorsScheme appColors = appColorsNotifier.value;

  ViewContentInfo? viewContentInfoResult;

  @override
  void initState() {
    super.initState();
    initDownloadCard();
  }


  Future<void> initDownloadCard() async {
    try{
      var getViewContentInfo = await ViewContentInfo.get_(
        source: widget.allDownloadItemKey.source, 
        id: widget.allDownloadItemKey.id, 
        fromCache: true
      );

      setState(() {
        viewContentInfoResult = getViewContentInfo;
      });
      // debugPrint(viewContentInfoResult.toString());
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void onNavigate(){
    Navigator.pushNamed(
      context,
      '/view',
      arguments: ViewScreenArguments(
        source: SourceExtension.fromString(widget.allDownloadItemKey.source), 
        id: widget.allDownloadItemKey.id
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (viewContentInfoResult == null) {
      return Container();
    }

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: onNavigate,
          
            child: Container(
              width: double.infinity,
              height: 225,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: appColors.strokePrimary),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 0,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                    clipBehavior: Clip.hardEdge,
                    child: Ink.image(
                      image: (viewContentInfoResult?.thumbnailUrl??"").isEmpty
                        ? const AssetImage("assets/thumbnail_placeholder.png")
                          : (viewContentInfoResult?.thumbnailUrl??"").startsWith("http")
                            ? NetworkImage(
                              viewContentInfoResult?.thumbnailUrl??"",
                            )
                            : FileImage(File(viewContentInfoResult?.thumbnailUrl??"")),
                      width: 150,
                      height: 225,
                      fit: BoxFit.fill,
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(left: 15, top: 15, right: 15),
                    child: Text(
                      viewContentInfoResult?.title??"",
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight(800)
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                  
                ],
              ),
            ),

          ),
          Container(
            width: double.infinity,
            height: max(300, MediaQuery.of(context).size.height * 0.35),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              color: appColors.primary,
              border: Border.all(color: appColors.strokePrimary),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
            ),
            child: ListView.separated(
              itemCount: widget.allDownloadItemValueList.length,
              itemBuilder: (context,index){
                return DownloadTile(
                  key: ValueKey(widget.allDownloadItemValueList[index]),
                  index: index,
                  allDownloadItemKey: widget.allDownloadItemKey,
                  allDownloadItemValue: widget.allDownloadItemValueList[index],
                  onRemoveDownload: ()=> widget.onRemoveDownload(widget.allDownloadItemKey, index),
                );
              }, 
              separatorBuilder: (_,__){
                return Container(
                  width: double.infinity,
                  height: 1,
                  color: appColors.strokePrimary
                );
              }, 
            )
          ),
          
        ],
      )
    );
  }
}