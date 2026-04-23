import 'package:file_type_plus/file_type_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';

import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:recombox/src/routes/select_file/widgets/select_file_tile.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/select_plugin/widgets/select_plugin_tile.dart';
import 'package:recombox/src/routes/select_source/widgets/select_source_tile.dart';
import 'package:recombox/src/routes/select_torrent/widgets/select_torrent_tile.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';
import 'package:path/path.dart' as path;

import 'package:recombox/src/rust/method/plugin_provider/get_sources.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_torrents.dart';

import 'dart:io';

import 'package:recombox/src/rust/method/torrent_provider/get_torrent_metadata.dart';


class SelectFileScreenArguments {
  String viewID;
  Source source;
  String torrentSource;
  BigInt season;
  BigInt episode;

  SelectFileScreenArguments({
    required this.viewID,
    required this.source,
    required this.torrentSource,
    required this.season,
    required this.episode
  });
}



class SelectFileScreen extends StatefulWidget {
  const SelectFileScreen({super.key});

  @override
  State<SelectFileScreen> createState() => _SelectFileState();
}

class _SelectFileState extends State<SelectFileScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  bool isLoading = false;

  String torrentName = "?";
  List<FileInfo> fileList = [];


  final TextEditingController _textEditingController = TextEditingController(text: '');
  FocusNode searchFocus = FocusNode();

  SelectFileScreenArguments? args;
  
  @override

  void initState() {
    super.initState();

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        
        args = rawArgs is SelectFileScreenArguments
            ? rawArgs
            : SelectFileScreenArguments(
              viewID: "72673844%20spider",
              source: Source.tv,
              torrentSource: "magnet:?xt=urn:btih:62EDE09B4E617C4C688D86B349F07290C3101238&dn=Loki.S02E01.WEB.x264-TORRENTGALAXY&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.bittor.pw%3A1337%2Fannounce&tr=udp%3A%2F%2Fpublic.popcorn-tracker.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969&tr=udp%3A%2F%2Fopen.demonii.com%3A1337%2Fannounce&tr=udp%3A%2F%2Fglotorrents.pw%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337",
              season: BigInt.from(1),
              episode: BigInt.from(1)
            );
      });
      debugPrint("--");
      debugPrint(args!.season.toString());
      debugPrint(args!.episode.toString());

      initSelectFile();
    });
  }

  @override
  void dispose() {

    super.dispose();
    
    
  }

  Future<void> initSelectFile() async {
    if (context.mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try{
      TorrentMetadata getTorrentInfoResult = await getTorrentMetadata(
        torrentSource: args!.torrentSource
      );
      List<FileInfo> fileListResult = getTorrentInfoResult.files.where((f){
        if (f.path == null) return false;

        String filename = path.basename(f.path??"");
        final fileType = FileType.fromPath(filename);

        debugPrint(filename);
        debugPrint(fileType.toString());
        debugPrint((fileType == FileType.video).toString());

        if (fileType == FileType.video) return true;
        
        
        return false;
      }).toList();

      if (context.mounted) {
        setState(() {
          torrentName = getTorrentInfoResult.name??"?";
          fileList = fileListResult;
        });
      }


      debugPrint(fileListResult.toString());

    }catch(e){
      debugPrint(e.toString());
    }finally{
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
      
    }

  }

  List<FileInfo> onFilterSearch() {
    final query = _textEditingController.text.toLowerCase();

    return fileList
        .where((element) {
          String filename = element.path??"";

          return filename.toLowerCase().contains(query)
            || element.id.toString().contains(query);
        })
        .toList();
  }





  @override
  Widget build(BuildContext context) {
    List<FileInfo> filteredFileList = onFilterSearch();

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
                              'Select File',
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
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            "Torrent Name: $torrentName",
                            style: GoogleFonts.nunito(
                              color: appColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      searchFocus.requestFocus();
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
                                                  filteredFileList = onFilterSearch();
                                                });
                                              },
                                              onSubmitted: (_){
                                                setState(() {
                                                  filteredFileList = onFilterSearch();
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
                                          ),
                                        ],
                                      )
                                    )
                                  ),
                                ),
                              
                                IconButton(
                                  mouseCursor: SystemMouseCursors.click,
                                  onPressed: initSelectFile,
                                  icon: Icon(Icons.refresh),
                                  color: appColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // <-
                        if (filteredFileList.isNotEmpty)
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredFileList.length,
                              itemBuilder: (context, index) {
                                return SelectFileTile(
                                  key: ValueKey(filteredFileList[index].id),
                                  source: args!.source, 
                                  viewID: args!.viewID, 
                                  torrentSource: args!.torrentSource,
                                  fileInfo: filteredFileList[index],
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
                        if (filteredFileList.isEmpty)
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "No file found from torrent.",
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