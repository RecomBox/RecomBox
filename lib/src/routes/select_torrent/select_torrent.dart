import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';

import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/select_plugin/widgets/select_plugin_tile.dart';
import 'package:recombox/src/routes/select_source/widgets/select_source_tile.dart';
import 'package:recombox/src/routes/select_torrent/widgets/select_torrent_tile.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';

import 'dart:io';

import 'package:recombox/src/rust/method/plugin_provider/get_sources.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_torrents.dart';

class SelectTorrentScreenArguments {
  String viewID;
  String pluginPath;
  String id;
  Source source;
  BigInt season;
  BigInt episode;

  SelectTorrentScreenArguments({
    required this.viewID,
    required this.pluginPath,
    required this.id,
    required this.source,
    required this.season,
    required this.episode
  });
}

class SelectTorrentScreen extends StatefulWidget {
  const SelectTorrentScreen({super.key});

  @override
  State<SelectTorrentScreen> createState() => _SelectTorrentState();
}

class _SelectTorrentState extends State<SelectTorrentScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  bool isLoading = false;

  List<TorrentInfo> torrentList = [];


  final TextEditingController _textEditingController = TextEditingController(text: '');
  FocusNode searchFocus = FocusNode();

  SelectTorrentScreenArguments? args;
  
  @override

  void initState() {
    super.initState();

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        
        args = rawArgs is SelectTorrentScreenArguments
            ? rawArgs
            : SelectTorrentScreenArguments(
              viewID: "72673844%20spider",
              pluginPath: "movies/8c8fb2b288439bcd9a71ff75051af9922162ba23b8a8ebd3db1dbe905cca00ee/2036011253247552227.js", 
              id: "72673844",
              source: Source.anime,
              season: BigInt.from(1),
              episode: BigInt.from(1)
            );
      });
      
      debugPrint("--");
      debugPrint(args!.season.toString());
      debugPrint(args!.episode.toString());
      
      initSelectTorrent();
    });
  }

  @override
  void dispose() {

    super.dispose();
    
    
  }

  Future<void> initSelectTorrent() async {
    if (!context.mounted) return;

    setState(() {
      isLoading = true;
    });
    try{

      List<TorrentInfo> getTorrentListResult = await getTorrents(
        pluginPath: args!.pluginPath,
        source: args!.source.name,
        id: args!.id,
        page: BigInt.from(1)
      );
      if (context.mounted){
        setState(() {
          torrentList = getTorrentListResult;
        });
      }

      debugPrint(getTorrentListResult.toString());



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

  List<TorrentInfo> onFilterSearch() {
    final query = _textEditingController.text.toLowerCase();

    return torrentList
        .where((element) {
          return element.title.toLowerCase().contains(query)
            || element.torrentUrl.toLowerCase().contains(query);
        })
        .toList();
  }





  @override
  Widget build(BuildContext context) {
    List<TorrentInfo> filteredTorrentList = onFilterSearch();

    if (args == null) return Container();
    
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              TitleBar(),
            Expanded(
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    spacing: 0,
                    children: [
                      
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          spacing: 10,
                          children: [
                            IconButton(
                              mouseCursor: SystemMouseCursors.click,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: appColors.secondary,
                              ),
                            ),
                            Text(
                              'Select Torrent',
                              style: GoogleFonts.nunito(
                                color: appColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight(600),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),

                      if (isLoading) 
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: appColors.secondary,
                              
                              ),
                            ),
                          )
                        ),
                      if (!isLoading) ...[
                        // -> Search Widget
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: appColors.strokePrimary
                                )
                              )
                            ),
                            width: double.infinity,
                            height: 60,
                            child: GestureDetector(
                              onTap: (){
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                height: double.infinity,
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: appColors.textPrimary,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _textEditingController,
                                        onChanged: (_){
                                          setState(() {
                                            filteredTorrentList = onFilterSearch();
                                          });
                                        },
                                        onSubmitted: (_){
                                          setState(() {
                                            filteredTorrentList = onFilterSearch();
                                          });
                                        },
                                        cursorColor: appColors.textPrimary,
                                        focusNode: searchFocus,
                                        style: GoogleFonts.nunito(
                                          fontSize: 24,
                                          color: appColors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Search",
                                          hintStyle: TextStyle(
                                            color: appColors.textPrimary,
                                          )
                                        ),
                                      )
                                    )
                                  ],
                                )
                              )
                            )
                          ),

                        ),
                        // <-
                        if (filteredTorrentList.isNotEmpty)
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredTorrentList.length,
                              itemBuilder: (context, index) {
                                return SelectTorrentTile(
                                  key: ValueKey(filteredTorrentList[index].torrentUrl),
                                  source: args!.source,
                                  viewID: args!.viewID,
                                  torrentInfo: filteredTorrentList[index],
                                  season: args!.season,
                                  episode: args!.episode
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 1,
                                  color: appColors.strokePrimary,
                                );
                              },
                            ),
                          ),
                        if (filteredTorrentList.isEmpty)
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "No torrent found.",
                                style: GoogleFonts.nunito(
                                  color: appColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ],
                  ),
                  
                ),
              
              
            )
          
          ],
        )
      )
    );
  }
}