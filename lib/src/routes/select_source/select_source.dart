import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/dialogs/install_plugin/install_plugin_dialog.dart';
import 'package:recombox/src/global/types.dart';

import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/select_plugin/widgets/select_plugin_tile.dart';
import 'package:recombox/src/routes/select_source/widgets/select_source_tile.dart';
import 'package:recombox/src/rust/method/plugin_provider/get_installed_plugins.dart';

import 'dart:io';

import 'package:recombox/src/rust/method/plugin_provider/get_sources.dart';

class SelectSourceScreenArguments {
  String pluginPath;
  SelectPluginScreenArguments selectPluginScreenArguments;


  SelectSourceScreenArguments({
    required this.pluginPath,
    required this.selectPluginScreenArguments
  });
}

class SelectSourceScreen extends StatefulWidget {
  const SelectSourceScreen({super.key});

  @override
  State<SelectSourceScreen> createState() => _SelectSourceState();
}

class _SelectSourceState extends State<SelectSourceScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  bool isLoading = false;

  List<SourceInfo> sourceInfoList = [];


  final TextEditingController _textEditingController = TextEditingController(text: '');
  FocusNode searchFocus = FocusNode();

  SelectSourceScreenArguments? args;
  
  @override

  void initState() {
    super.initState();

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        
        args = rawArgs is SelectSourceScreenArguments
            ? rawArgs
            : SelectSourceScreenArguments(
              pluginPath: "movies/8c8fb2b288439bcd9a71ff75051af9922162ba23b8a8ebd3db1dbe905cca00ee/2036011253247552227.js", 
              selectPluginScreenArguments: SelectPluginScreenArguments(
                  source: Source.movies,
                  id: "%2F53906%2Fspider-man",
                  externalID: "tt999",
                  title: "Spiderman",
                  titleSecondary: "Spiderman",
                  season: BigInt.from(1),
                  episode: BigInt.from(1)
                  
              )
            );
      });
      debugPrint(args.toString());
      initSelectSource();
    });
  }

  @override
  void dispose() {

    super.dispose();
    
    
  }

  Future<void> initSelectSource() async {
    setState(() {
      isLoading = true;
    });
    try{

      
      List<SourceInfo> getSourceInfoResult = await getSources(
        pluginPath: args!.pluginPath, 
        source: args!.selectPluginScreenArguments.source.name, 
        id: args!.selectPluginScreenArguments.externalID, 
        title: args!.selectPluginScreenArguments.title, 
        titleSecondary: args!.selectPluginScreenArguments.titleSecondary,
        season: args!.selectPluginScreenArguments.season+BigInt.from(1), 
        episode: args!.selectPluginScreenArguments.episode+BigInt.from(1), 
        search: _textEditingController.text, 
        page: BigInt.from(1)
      );

      setState(() {
        sourceInfoList = getSourceInfoResult;
      });

    }catch(e){
      debugPrint(e.toString());
    }finally{
      setState(() {
        isLoading = false;
      });
    }

  }

  List<SourceInfo> onFilterSearch() {
    final query = _textEditingController.text.toLowerCase();

    return sourceInfoList
        .where((element) {
          return element.title.toLowerCase().contains(query);
        })
        .toList();
  }





  @override
  Widget build(BuildContext context) {
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
                              'Select Source',
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
                      // -> Default filter info
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          "Title: ${args!.selectPluginScreenArguments.title}",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          "Secondary Title: ${args!.selectPluginScreenArguments.titleSecondary}",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      
                      if (args!.selectPluginScreenArguments.source != Source.movies)
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            "Season: ${args!.selectPluginScreenArguments.season+BigInt.from(1)}, Episode: ${args!.selectPluginScreenArguments.episode+BigInt.from(1)}",
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
                        
                      // <-
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
                                        
                                        onSubmitted: (_){
                                          initSelectSource();
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
                        if (sourceInfoList.isNotEmpty)
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: sourceInfoList.length,
                              itemBuilder: (context, index) {
                                return SelectSourceTile(
                                  key: ValueKey(sourceInfoList[index].id),
                                  viewID: args!.selectPluginScreenArguments.id,
                                  pluginPath: args!.pluginPath,
                                  source: args!.selectPluginScreenArguments.source,
                                  sourceInfo: sourceInfoList[index],
                                  season: args!.selectPluginScreenArguments.season,
                                  episode: args!.selectPluginScreenArguments.episode
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
                        if (sourceInfoList.isEmpty)
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "No source found from default filter.\nYou can try search yourself.",
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