import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/home/widgets/content_section.dart';
import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';
import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';
import 'package:recombox/src/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

// -> Local Widgets
import 'package:recombox/src/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'package:recombox/src/widgets/title_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/featured_section.dart';
// <-

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {

  bool isLoading = false;

	List<FeaturedContentInfo> featuredContentList = [];
	Map<Source, List<TrendingContentInfo>> trendingContentMap = {};

  AppColorsScheme appColors = appColorsNotifier.value;


  @override
  void initState() {
    super.initState();

    initMetadataProvider();
  }

  Future<void> initMetadataProvider({bool fromCache=true}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });
    try{
      await Future.wait([
        (() async{
          // -> Featured Content
          final waitResult = await Future.wait([
            for (final source in Source.values)
              featuredContent(source: source.name, fromCache: fromCache),
          ]);

          List<FeaturedContentInfo> featuredContentListResult = [];

          for (final result in waitResult) {
            featuredContentListResult.addAll(result);
          }
          setState(() {
            featuredContentList = featuredContentListResult..shuffle(Random());
          });
              
          // <-
        })(),
        
        (() async{
          // -> Trending Content
          var waitResult = await Future.wait([
            for (final source in Source.values)
              trendingContent(source: source.name, fromCache: fromCache),
          ]);

          Map<Source, List<TrendingContentInfo>> trendingContentMapResult = {};

          // zip Source.values with waitResult
          for (int i = 0; i < Source.values.length; i++) {
            trendingContentMapResult[Source.values[i]] = waitResult[i];
          }

          setState(() {
            trendingContentMap = trendingContentMapResult;
          });
          // <-
        })()
      ]);
    }catch(e){
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600)
            NavigationBarVertical(
              currentIndex: 0,
            ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  if (isLoading)
                    Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: appColors.secondary,
                      )
                    ),
                  if (!isLoading)
                    SizedBox(
                      height: double.infinity,
                      child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: MediaQuery.of(context).size.height * 0.55,
                                      viewportFraction: 1.0,
                                      autoPlay: featuredContentList.isEmpty ? false : true,
                                      autoPlayInterval: Duration(seconds: 8),
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                    ),
                                    items: [
                                      for (final item in featuredContentList)
                                        FeaturedSection(
                                          featuredContentInfo: item,
                                        ),
                                    ],
                                  ),
                                  
                                  if (!((Platform.isWindows || Platform.isLinux || Platform.isMacOS)))
                                    Container(
                                      padding: EdgeInsets.only(right: 10, top: 10),
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                          mouseCursor: SystemMouseCursors.click,
                                          onTap: () {
                                            initMetadataProvider(fromCache: false);
                                          },
                                          child: Icon(
                                            color: appColors.secondary,
                                            Icons.refresh
                                          )
                                        )
                                    ),
                                    
                                ]
                              ),
                              for (final source in trendingContentMap.keys)
                                ContentSection(
                                  label: "Trending ${source.label}",
                                  trendingContentList: trendingContentMap[source]!,
                                ),
                            ]
                          )
                        ),
                    ),
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                      Positioned(top: 0, left: 0, right: 0, 
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                onPressed: () {
                                  initMetadataProvider(fromCache: false);
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  color: appColors.secondary,
                                ),
                              ),
                              Expanded(child: TitleBar())
                            ],
                          )
                        )
                      ),
                ],
              ),
              bottomNavigationBar: ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) && (MediaQuery.of(context).size.width < 600)) 
                ?  NavigationBarHorizontal(
                    currentIndex: 0,
                  )
                : null,
            ),
          )
        ],
      )
    );
  }
}
