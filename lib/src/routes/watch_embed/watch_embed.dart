import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/global/widgets/title_bar.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'; // for Factory
// for gesture recognizers
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'package:recombox/src/rust/method/watch_state.dart';
import 'package:recombox/src/rust/method/watch_state/set_watch_state.dart';
import 'package:window_manager/window_manager.dart';


// Linux use this Command
// ---
// WPE_DISABLE_DMABUF=1 WEBKIT_DISABLE_COMPOSITING_MODE=1 LIBGL_ALWAYS_SOFTWARE=1 flutter run -d linux
// ---

class WatchEmbedArguments{
  String viewID;
  Source source;
  ExternalID externalID;
  int season;
  int episode;

  WatchEmbedArguments({
    required this.viewID,
    required this.source,
    required this.externalID,
    required this.season,
    required this.episode
  });
}

class WatchEmbedScreen extends StatefulWidget {
  const WatchEmbedScreen({super.key});

  @override
  State<WatchEmbedScreen> createState() => _WatchEmbedState();
}

class _WatchEmbedState extends State<WatchEmbedScreen> {
  late WatchEmbedArguments args;


  AppColorsScheme appColors = appColorsNotifier.value;
  InAppWebViewController? webViewController;
  final GlobalKey _webViewKey = GlobalKey();
  
  bool isFullScreen = false;
  String currentUrl = "";

  // final FocusNode _focusNode = FocusNode();
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;

      args = rawArgs is WatchEmbedArguments
          ? rawArgs
          : WatchEmbedArguments(
              viewID: "94997",
              source: Source.tv,
              externalID: ExternalID(tmdb: "94997"),
              season: 0,
              episode: 0
          );

      debugPrint(args.toString());
      
      String url;
      if (args.source == Source.movies) {
        url = "https://player.vidlove.cc/embed/movie/${args.externalID.tmdb}?primarycolor=ff4d6d&secondarycolor=c49de8";
      }else{
        url = "https://player.vidlove.cc/embed/tv/${args.externalID.tmdb}/${args.season+1}/${args.episode+1}?primarycolor=ff4d6d&secondarycolor=c49de8";
      }
    
      setState(() {
        currentUrl = url;
        _ready = true;
      });

      init();
    
    });

    
  }



  
  Future<void> init() async {
    await setWatchState(
      watchStateKey: WatchStateKey(
        source: args.source.name,
        id: args.viewID,
        seasonIndex: BigInt.from(args.season),
        episodeIndex: BigInt.from(args.episode)
      ),
      watchStateValue: WatchStateValue(
        position: BigInt.from(0)
      )
    );
  }

  void onNavigateBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, "/home");
    }

  }

  @override
  void dispose() {
    // Clean up the webview controller
    webViewController?.dispose();
    webViewController = null;
    super.dispose();
  }

  void onWatchNext() async {
    final ctx = context;
    final viewContentInfoResult = await ViewContentInfo.get_(
      source: args.source.name,
      id: args.viewID,
      fromCache: true,
      checkExpire: false
    );

    final episodeList = viewContentInfoResult.episodes;

    bool availableNext = false;

    int nextSeasonIndex = args.season.toInt();
    int nextEpisodeIndex = args.episode.toInt() + 1;

    if (nextEpisodeIndex >= (episodeList[nextSeasonIndex].toInt() - 1)){
      nextEpisodeIndex = 0;
      nextSeasonIndex++;
      if (nextSeasonIndex >= episodeList.length){
        availableNext = false;
      }else if (episodeList[nextSeasonIndex].toInt() == 0){
        availableNext = false;
      }else{
        availableNext = true;
      }
      
    }else{
      availableNext = true;
    }


    if (availableNext && ctx.mounted){
      await setWatchState(
        watchStateKey: WatchStateKey(
          source: args.source.name,
          id: args.viewID,
          seasonIndex: BigInt.from(nextSeasonIndex),
          episodeIndex: BigInt.from(nextEpisodeIndex)
        ),
        watchStateValue: WatchStateValue(
          position: BigInt.from(0)
        )
      );

      setState(() {
        args = WatchEmbedArguments(
          viewID: args.viewID,
          source: args.source,
          externalID: args.externalID,
          season: nextSeasonIndex,
          episode: nextEpisodeIndex
        );

        currentUrl = "https://player.vidlove.cc/embed/tv/${args.externalID.tmdb}/${args.season+1}/${args.episode+1}?primarycolor=ff4d6d&secondarycolor=c49de8";
        webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));

      });
    }
    
  }

  void onWatchPrevious() async {
    final ctx = context;

    bool availableNext = false;

    int nextSeasonIndex = args.season.toInt();
    int nextEpisodeIndex = args.episode.toInt() - 1;

    if (nextEpisodeIndex < 0){
      nextEpisodeIndex = 0;
      nextSeasonIndex--;
      if (nextSeasonIndex < 0){
        availableNext = false;
      }else{
        availableNext = true;
      }
    }else{
      availableNext = true;
    }
    

    if (availableNext && ctx.mounted){
      await setWatchState(
        watchStateKey: WatchStateKey(
          source: args.source.name,
          id: args.viewID,
          seasonIndex: BigInt.from(nextSeasonIndex),
          episodeIndex: BigInt.from(nextEpisodeIndex)
        ),
        watchStateValue: WatchStateValue(
          position: BigInt.from(0)
        )
      );

      setState(() {
        args = WatchEmbedArguments(
          viewID: args.viewID,
          source: args.source,
          externalID: args.externalID,
          season: nextSeasonIndex,
          episode: nextEpisodeIndex
        );

        currentUrl = "https://player.vidlove.cc/embed/tv/${args.externalID.tmdb}/${args.season+1}/${args.episode+1}?primarycolor=ff4d6d&secondarycolor=c49de8";
        
        webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));
        
        
      });
      
    }
    
  }


  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }else{
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
                if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) && !isFullScreen)
                  TitleBar(),
                if (!isFullScreen)
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: onNavigateBack,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: appColors.secondary,
                          ),
                          iconSize: 32,
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            IconButton(
                              mouseCursor: SystemMouseCursors.click,
                              onPressed: (){
                                webViewController?.goBack();
                              },
                              icon: Icon(
                                Icons.keyboard_double_arrow_left_rounded,
                                color: appColors.secondary,
                              ),
                              iconSize: 32,
                            ),
                            IconButton(
                              mouseCursor: SystemMouseCursors.click,
                              onPressed: (){
                                webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));

                              },
                              icon: Icon(
                                Icons.refresh_rounded,
                                color: appColors.secondary,
                              ),
                              iconSize: 32,
                            ),
                          ]
                        )
                      ],
                    ),
                  ),
                  
                Expanded(
                  child: Row(
                    children: [
                      if (!isFullScreen && args.source != Source.movies)
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: onWatchPrevious,
                            icon: Icon(
                              Icons.chevron_left_rounded,
                              color: appColors.secondary,
                            ),
                            iconSize: 32,
                          ),
                        ),

                      Expanded(
                        child: LayoutBuilder(
                          key: _webViewKey,
                          builder: (context, constraints) {
                            return InAppWebView(
                              
                              initialSettings: InAppWebViewSettings(
                                mediaPlaybackRequiresUserGesture: false,
                                allowsInlineMediaPlayback: true,
                                javaScriptEnabled: true,
                                domStorageEnabled: true,        
                                databaseEnabled: true,        
                                cacheEnabled: true,            
                                thirdPartyCookiesEnabled: true, 
                                
                              ),
                              initialUrlRequest: URLRequest(
                                url: WebUri(currentUrl),
                              ),
                              onWebViewCreated: (controller) {
                                webViewController = controller;
                              },
                              onLoadStop: (controller, url) {
                                debugPrint("Page finished loading: $url");
                              },
                              onLoadStart: (controller, url) {
                                debugPrint("Page started loading: $url");
                              },
                              onEnterFullscreen: (controller)async{
                                var ctx = context;
                                debugPrint("Enter fullscreen");
                                if (Platform.isLinux || Platform.isWindows || Platform.isMacOS){
                                  await windowManager.setFullScreen(true);
                                }
                                if (ctx.mounted) {
                                  setState(() {
                                    isFullScreen = true;
                                  });
                                }
                              },
                              onExitFullscreen: (controller) async {
                                var ctx = context;
                                debugPrint("Exit fullscreen");
                                if (Platform.isLinux || Platform.isWindows || Platform.isMacOS){
                                  await windowManager.setFullScreen(false);
                                }
                                if (ctx.mounted) {
                                  setState(() {
                                    isFullScreen = false;
                                  });
                                }
                                
                              },

                              shouldOverrideUrlLoading: (controller, navigationAction) async {
                                final uri = navigationAction.request.url;
                                if (uri != null) {
                                  // Allow only vidlove.cc and its subdomains
                                  if (uri.host.endsWith("vidlove.cc")) {
                                    return NavigationActionPolicy.ALLOW;
                                  } else {
                                    debugPrint("❌ Blocked navigation to: $uri");
                                    return NavigationActionPolicy.CANCEL;
                                  }
                                }
                                return NavigationActionPolicy.CANCEL;
                              },
                            );
                          },
                        )
                      ),
                      
                      if (!isFullScreen && args.source != Source.movies)

                        Container(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: onWatchNext,
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              color: appColors.secondary,
                            ),
                            iconSize: 32,
                          ),
                        )
                    
                    ],
                  )
                )
                
            
              
            ],
          )
        )
      );
    }
  }
}
