import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/route_observer.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/home/widgets/content_section.dart';
import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';
import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/favorite/recent_watch.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

// -> Local Widgets
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'package:recombox/src/global/widgets/title_bar.dart';
import 'widgets/featured_section.dart';
// <-

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with RouteAware {

  bool isLoading = false;
  bool isError = false;

	List<FeaturedContentInfo> featuredContentList = [];
	Map<Source, List<TrendingContentInfo>> trendingContentMap = {};
	List<(RecentWatchInfo, ViewContentInfo)> recentWatchList = [];

  AppColorsScheme appColors = appColorsNotifier.value;


  @override
  void initState() {
    super.initState();

    initMetadataProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  // Called when a route pushed on top of this one is popped: reload so
  // e.g. the continue-watching section updates.
  @override
  void didPopNext() {
    initMetadataProvider();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> initMetadataProvider({bool fromCache=true}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      isError = false;
    });
    List<FeaturedContentInfo> featuredContentListResult = [];
    Map<Source, List<TrendingContentInfo>> trendingContentMapResult = {};
    List<(RecentWatchInfo, ViewContentInfo)> recentWatchListResult = [];

    try{
      await Future.wait([
        // -> Featured Content
        (() async{
          final waitResult = await Future.wait([
            for (final source in Source.values)
              featuredContent(source: source.name, fromCache: fromCache),
          ]);
          for (final result in waitResult) {
            featuredContentListResult.addAll(result);
          }
          featuredContentListResult = featuredContentListResult..shuffle(Random());
        })(),
        // <-
        
        // -> Trending Content
        (() async{
          var waitResult = await Future.wait([
            for (final source in Source.values)
              trendingContent(source: source.name, fromCache: fromCache),
          ]);

          for (int i = 0; i < Source.values.length; i++) {
            trendingContentMapResult[Source.values[i]] = waitResult[i];
          }
        })(),
        // <-

        // -> Recent Watch
        (() async{
          List<RecentWatchInfo> recentWatch = [];
          try {
            recentWatch = await getAllRecentWatch();
          } catch (e) {
            // Don't fail the whole home page if only recent watch fails.
            debugPrint("getAllRecentWatch: $e");
          }
          // Fetch each show's info; skip any that fail so one bad entry
          // doesn't hide the whole section. Order is kept (most recent first).
          final infoResult = await Future.wait([
            for (final item in recentWatch)
              ViewContentInfo.get_(source: item.source, id: item.id, fromCache: fromCache, checkExpire: true)
                .then<ViewContentInfo?>((data) => data)
                .catchError((e) {
                  debugPrint("Recent watch ${item.source}/${item.id}: $e");
                  return null;
                }),
          ]);
          for (int i = 0; i < recentWatch.length; i++) {
            final info = infoResult[i];
            if (info != null) recentWatchListResult.add((recentWatch[i], info));
          }
        })()
        // <-
      ]);
    }catch(e){
      debugPrint(e.toString());
      if (context.mounted){
        setState(() {
          isError = true;
        });
      }
    }

    setState(() {
      featuredContentList = featuredContentListResult;
      trendingContentMap = trendingContentMapResult;
      recentWatchList = recentWatchListResult;
      isLoading = false;
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
                currentName: 'home',
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
                      )
                    else if (isError)
                        Positioned.fill(
                            child: Container(
                              padding: EdgeInsets.all(15),
                              alignment: Alignment.center,
                              child: Text(
                                "Something went wrong while fetching content",
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  color: appColors.textPrimary,
                                  fontWeight: FontWeight(700)
                                ),
                                textAlign: TextAlign.center,
                              )
                          ),
                        )
                    else
                        SizedBox(
                          height: double.infinity,
                          child: SingleChildScrollView(
                              physics: ScrollPhysics(),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CarouselSlider(
                                        options: CarouselOptions(
                                          height: MediaQuery.of(context).size.height * 0.5,
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
                                  if (recentWatchList.isNotEmpty)
                                    ContentSection(
                                      label: "Continue Watching",
                                      recentWatchList: recentWatchList,
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
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                bottomNavigationBar: (MediaQuery.of(context).size.width < 600)
                  ?  NavigationBarHorizontal(
                      currentName: 'home',
                    )
                  : null,
              ),
            )
          ],
        )
      )
    );
  }
}
