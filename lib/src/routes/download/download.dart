import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/download/widgets/download_card.dart';
import 'package:recombox/src/routes/search/widgets/search_tile.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_all_download.dart';
import 'package:recombox/src/rust/method/download_provider/remove_download.dart';
import 'package:recombox/src/rust/method/metadata_provider/search_content.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'dart:io';
import 'dart:async';

import 'package:recombox/src/global/widgets/title_bar.dart';

Map<int, String> availableSorts = {
  0: "Relevance",
  1: "Rank",
  2: "Release Date",
};

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => DownloadState();
}

class DownloadState extends State<DownloadScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  Map<AllDownloadItemKey, List<AllDownloadItemValue>> allDownloadMap = {};


  bool isLoading = false;

  Source currentSource = Source.anime;
  int currentSortIndex = 0;
  int currentPage = 1;
  String currentSearch = "";

  FocusNode searchFocus = FocusNode();
  late TextEditingController _textEditingController;
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: currentSearch);
    setState(() {

      currentSource = Source.anime;
      currentSortIndex = 0;
      currentPage = 1;
    });
    initDownload();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  

  Future<void> initDownload() async {
    debugPrint(currentPage.toString());
    setState(() {
      isLoading = true;
    });
    try{
      final result = await getAllDownload();

      var sortedKeys = result.keys.toList()..sort((a, b) {
        int sourceResult = a.source.compareTo(b.source);
        
        if (sourceResult == 0) {
          return a.id.compareTo(b.id);
        }
        
        return sourceResult;
      });

      final Map<AllDownloadItemKey, List<AllDownloadItemValue>> sortedResult = {
        for (var key in sortedKeys) key: result[key]! 
      };

      // debugPrint(result.toString());
      if (context.mounted){
        setState(() {
          allDownloadMap = sortedResult;
        });
      }
    }catch(e){
      debugPrint(e.toString());
    }
    
    
    if (context.mounted){
      setState(() {
        isLoading = false;
      });
    }
    
  }

  Future<void> onRemoveDownload(AllDownloadItemKey key, int index) async {
    try{
      await removeDownload(downloadItemKey: DownloadItemKey(
        source: key.source, 
        id: key.id, 
        seasonIndex: allDownloadMap[key]![index].seasonIndex, 
        episodeIndex: allDownloadMap[key]![index].episodeIndex
      ));
      
    }catch(e){
      debugPrint(e.toString());
    }

    setState(() {
      allDownloadMap[key]!.removeAt(index);
      if (allDownloadMap[key]!.isEmpty){
        allDownloadMap.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 600)
              NavigationBarVertical(
                currentIndex: 3,
              ),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  spacing: 0,
                  children: [
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                      TitleBar(),
                      if (allDownloadMap.isNotEmpty)
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            child: ListView.separated(
                                itemCount: allDownloadMap.keys.length,
                                itemBuilder: (context, index){
                                  return DownloadCard(
                                    key: ValueKey(allDownloadMap.keys.toList()[index]),
                                    allDownloadItemKey: allDownloadMap.keys.toList()[index],
                                    allDownloadItemValueList: allDownloadMap.values.toList()[index],
                                    onRemoveDownload: onRemoveDownload,
                                  );
                                }, 
                                separatorBuilder: (_,__){
                                  return  SizedBox(height: 10,);
                                }, 
                              ),
                            
                          )
                        ),
                      if (allDownloadMap.isEmpty)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            alignment: Alignment.center,
                            child: Text(
                              "No download found",
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                color: appColors.textPrimary,
                                fontWeight: FontWeight(700)
                              ),
                              textAlign: TextAlign.center,
                            )
                          ),
                        )
                  ],
                ),
                bottomNavigationBar: (MediaQuery.of(context).size.width < 600)
                  ? NavigationBarHorizontal(
                    currentIndex: 3,
                  )
                  : null
              )
            ),

          ],
        )
      )
    );
  }
}