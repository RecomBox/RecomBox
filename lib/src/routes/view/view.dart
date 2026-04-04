import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/widgets/episode_tile.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'dart:io';
import 'dart:math';

import 'package:recombox/src/widgets/title_bar.dart';

class ViewScreenArguments {
  Source source;
  String id;

  ViewScreenArguments({
    required this.source,
    required this.id
  });
}

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});
  

  @override
  State<ViewScreen> createState() => _ViewState();
}

class _ViewState extends State<ViewScreen> {

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;

      args = rawArgs is ViewScreenArguments
          ? rawArgs
          : ViewScreenArguments(
              source: Source.movies,
              id: "%2F53906%2Fspider-man",
          );

      debugPrint(args.toString());
      initViewContentInfo();

      
    });
  }

  @override
  void dispose() {
    super.dispose();
    _episodeScrollController.dispose();
    _seasonScrollController.dispose();
  }

  late ViewScreenArguments args;

  final _seasonScrollController = ScrollController();
  final _episodeScrollController = ScrollController();


  
  AppColorsScheme appColors = appColorsNotifier.value;

  late ViewContentInfo viewContentInfoResult;

  bool isLoading = false;
  int currentSeasonIndex = 0;
  int currentTabIndex = 0;
  var tabList = [
    {
      "icon": Icons.list,
      "label": "Episodes"
    },
    {
      "icon": Icons.panorama_rounded,
      "label": "Pictures"
    }
  ];

  void onSeasonChange(int index){
    setState(() {
      currentSeasonIndex = index;
    });
  }

  void onRefresh(){
    initViewContentInfo(fromCache: false);
  }

  void onBack(){
    Navigator.pop(context);
  }

  

  Future<void> initViewContentInfo({bool fromCache=true}) async {
    setState(() {
      isLoading = true;
    });
    var data = await viewContent(source: args.source.name, id: args.id, fromCache: fromCache);
    
    setState(() {
      viewContentInfoResult = data;
    });

    debugPrint(data.toString());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            if (isLoading) ...[
              if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
                Positioned(top: 0, left: 0, right: 0, 
                  child: Container(
                    padding: EdgeInsets.only(left: 8, right: 8,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: onBack,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: appColors.secondary,
                          ),
                        ),
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: onRefresh,
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: appColors.secondary,
                          ),
                        ),
                      ],
                    )
                  )
                ),
              
              Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: appColors.secondary,
                )
              ),
            ],
            if (!isLoading)
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: Stack(
                        children: [
                          Ink.image(
                            image: NetworkImage(viewContentInfoResult.bannerUrl),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withAlpha(60),
                          ),
                          Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: EdgeInsets.only(bottom: 15),
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      viewContentInfoResult.title,
                                      style: GoogleFonts.nunito(
                                        fontSize: 38,
                                        fontWeight: FontWeight(800),
                                        color: appColors.textPrimary,
                                        decoration: TextDecoration.none,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                      padding: EdgeInsets.only(left: 12),
                                      clipBehavior: Clip.hardEdge,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (final contextual in viewContentInfoResult.contextual)
                                            Container(
                                              margin: EdgeInsets.only(right: 8),
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: appColors.accentPrimary,
                                              ),
                                              child: Text(
                                                contextual,
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.normal,
                                                  color: appColors.textPrimary,
                                                  decoration: TextDecoration.none,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                        ],
                                      )),
                                
                                ],
                              )),
                        
                          if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
                            Positioned(top: 0, left: 0, right: 0, 
                              child: Container(
                                padding: EdgeInsets.only(left: 8, right: 8,),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      mouseCursor: SystemMouseCursors.click,
                                      onPressed: onBack,
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: appColors.secondary,
                                      ),
                                    ),
                                    IconButton(
                                      mouseCursor: SystemMouseCursors.click,
                                      onPressed: onRefresh,
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        color: appColors.secondary,
                                      ),
                                    ),
                                  ],
                                )
                              )
                            ),

                          
                        ]
                      ),
                    ),

                    // -> Button Container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () {

                            },
                            label: Text("Watch Now"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.secondary,
                              foregroundColor: appColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              )
                            ),
                          ),
                          TextButton(
                            onPressed: () {

                            },
                            style: IconButton.styleFrom(
                              backgroundColor: appColors.secondary,
                              foregroundColor: appColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              )
                            ),
                            child: Icon(Icons.bookmark_outline),
                          ),
                          TextButton(
                            onPressed: () {

                            },
                            style: IconButton.styleFrom(
                              backgroundColor: appColors.secondary,
                              foregroundColor: appColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              )
                            ),
                            child: Icon(Icons.video_library),
                          )
                        ],
                      )
                    ),
                    // <-
                    
                    // -> Description
                    if (viewContentInfoResult.description.isNotEmpty)
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          viewContentInfoResult.description,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: appColors.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // <-
                    if (viewContentInfoResult.description.isNotEmpty)
                      SizedBox(
                        height: 20,
                      ),

                    // -> Countdown
                    Container(
                      padding: EdgeInsets.all(10),
                      color: appColors.tertiary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Text(
                            "Countdown to next release:",
                            style: GoogleFonts.nunito(
                              fontSize: MediaQuery.of(context).size.width > 600 ? 32 : MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight(800),
                              color: appColors.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.start,
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: appColors.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              spacing: 8,
                              children: [
                                for (var entry in ["Days", "Hours", "Minutes", "Seconds"].asMap().entries)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          "6",
                                          style: GoogleFonts.nunito(
                                            fontSize: MediaQuery.of(context).size.width > 600 ? 32 : MediaQuery.of(context).size.width * 0.05,
                                            fontWeight: FontWeight(800),
                                            color: appColors.textPrimary,
                                            decoration: TextDecoration.none,
                                          ),
                                          maxLines: 1,
                                        ),
                                        Text(
                                          entry.value,
                                          style: GoogleFonts.nunito(
                                            fontSize: MediaQuery.of(context).size.width > 600 ? 32 : MediaQuery.of(context).size.width * 0.05,
                                            fontWeight: FontWeight(800),
                                            color: appColors.textPrimary,
                                            decoration: TextDecoration.none,
                                          ),
                                          maxLines: 1,
                                        )
                                      ],
                                    )
                                    
                                  )
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                    // <-

                    // -> SeasonList
                    if (viewContentInfoResult.episodes.length > 1)
                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        height: 100,
                          child: Scrollbar(
                            controller: _seasonScrollController,
                            thickness: (Platform.isWindows ||
                                    Platform.isLinux ||
                                    Platform.isMacOS)
                                ? null
                                : 0,
                            child: ListView.separated(
                              controller: _seasonScrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: viewContentInfoResult.episodes.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 130,
                                  child: TextButton(
                                    onPressed: () {
                                      onSeasonChange(index);
                                    },
                                    style: TextButton.styleFrom(
                                      enabledMouseCursor: SystemMouseCursors.click,
                                      side: BorderSide(color: appColors.tertiary, width: 2),
                                      backgroundColor: currentSeasonIndex == index ? appColors.tertiary : appColors.primary,
                                      foregroundColor: appColors.textPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      )
                                    ),
                                    
                                    child: Text("Season ${index + 1}"),
                                  )
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  width: 10,
                                );
                              },
                            ),
                          
                          )
                      ),
                    // <-

                    // -> TabList
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        spacing: 2.5,
                        children: [
                          for (var entry in tabList.asMap().entries)
                            ElevatedButton.icon(
                              onPressed: (){
                                setState(() {
                                  currentTabIndex = entry.key;
                                });
                              },
                              icon: Icon(entry.value["icon"] as IconData),
                              label: Text(entry.value["label"] as String),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentTabIndex == entry.key ? appColors.accentPrimary : appColors.secondary,
                                foregroundColor: currentTabIndex == entry.key ? appColors.secondary : appColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: currentTabIndex == entry.key 
                                    ? BorderRadius.circular(15)
                                    : entry.key == 0
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)
                                        )
                                      : entry.key == tabList.length - 1
                                        ? BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15)
                                        )
                                        : BorderRadius.zero
                                )
                              ),
                            )
                        ],
                      ),
                    ),
                    
                    // <-


                    IndexedStack(
                      index: currentTabIndex,
                      children: [
                      
                        // -> Episodes
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.6,
                          padding: EdgeInsets.all(10),
                          child: Scrollbar(
                            thickness: 0,
                            controller: _episodeScrollController,
                            
                            child: ListView.separated(
                              controller: _episodeScrollController,
                              scrollDirection: Axis.vertical,
                              itemCount: viewContentInfoResult.episodes.elementAtOrNull(currentSeasonIndex)?.length ?? 0,
                              itemBuilder: (current, index) {
                                  return EpisodeTile(
                                    episodeInfo: viewContentInfoResult.episodes[currentSeasonIndex][index],
                                  );
                              }, 
                              separatorBuilder: (current, index) {
                                return SizedBox(height: 10,);
                              },
                              
                            )
                          )
                        ),

                        // <- 
                        
                        // -> Pictures
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.6,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: GridView.count(
                            crossAxisCount: 2, // number of columns
                            crossAxisSpacing: 10, // horizontal spacing
                            mainAxisSpacing: 10, 
                            children: [
                              for (var pic in viewContentInfoResult.pictures)
                                Ink.image(
                                  width: 50,
                                  image: NetworkImage(pic),
                                ),
                            ],
                          )
                        )

                        // <-

                      ],
                    ),
                  ]

                  // <-
                )
              ),
            
              
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              Positioned(top: 0, left: 0, right: 0, 
                child: Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        onPressed: onBack,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: appColors.secondary,
                        ),
                      ),
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        onPressed: onRefresh,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: appColors.secondary,
                        ),
                      ),
                      Expanded(child: TitleBar())
                    ],
                  )
                )
              ),
            
          ]
        )
      )
    );
  }
}