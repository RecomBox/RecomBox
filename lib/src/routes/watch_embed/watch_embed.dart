import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/global/widgets/title_bar.dart';
import 'dart:async';
import 'dart:io';

// for gesture recognizers
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:recombox/src/rust/method/direct_stream_provider.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
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
  String currentPrefillUrl = "";
  String currentUrl = "";
  String currentId = "";
  List<String> allowedNavigationOrigin = [];

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

      init();
    
    });

    
  }



  
  Future<void> init() async {
    var ctx = context;
    ViewContentInfo viewContentInfo = await ViewContentInfo.get_(
      source: args.source.name,
      id: args.viewID,
      fromCache: true,
      checkExpire: false
    );

    if (viewContentInfo.selectedProvider?.id == null && ctx.mounted){
      Navigator.pop(ctx);
    }

    DirectStreamProvider streamProvider = await DirectStreamProvider.get_(
      id: viewContentInfo.selectedProvider!.id!
    );


    String? prefillUrl = await streamProvider.urlSchema.get_(s: args.source.name);

    if (prefillUrl == null && ctx.mounted){
      Navigator.pop(ctx);
    }

    String? idType = await streamProvider.idType.get_(s: args.source.name);

    if (idType == null && ctx.mounted){
      Navigator.pop(ctx);
    }

    String? externalId = await viewContentInfo.externalId.get_(s: idType!);

    if (externalId == null && ctx.mounted){
      Navigator.pop(ctx);
      showToastWidget(
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appColors.tertiary,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Text(
            "Unable to find available stream",
            style: GoogleFonts.nunito(
              color: appColors.textPrimary,
              fontSize: 16
            ),
          ),
        ),
        position: ToastPosition.bottom,
        dismissOtherToast: true,
      );
    }


    setState(() {
      currentId = externalId!;
      allowedNavigationOrigin = streamProvider.allowedNavigationOrigin;
      currentPrefillUrl = prefillUrl!;
      currentUrl = prefillUrl.replaceAll("{id}", currentId)
        .replaceAll("{season}", (args.season+1).toString())
        .replaceAll("{episode}", (args.episode+1).toString());

      debugPrint(currentUrl);
    });

    await ViewContentInfo.updateLastWatch(
      source: args.source.name, 
      id: args.viewID, 
      seasonIndex: BigInt.from(args.season), 
      episodeIndex: BigInt.from(args.episode)
    );

    setState(() {
      _ready = true;
    });
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
    try{
      webViewController?.dispose();
      webViewController = null;
    }catch(e){
      debugPrint(e.toString());
    }
    
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
      await ViewContentInfo.updateLastWatch(
        source: args.source.name, 
        id: args.viewID, 
        seasonIndex: BigInt.from(nextSeasonIndex), 
        episodeIndex: BigInt.from(nextEpisodeIndex)
      );

      setState(() {
        args = WatchEmbedArguments(
          viewID: args.viewID,
          source: args.source,
          externalID: args.externalID,
          season: nextSeasonIndex,
          episode: nextEpisodeIndex
        );

        currentUrl = currentPrefillUrl.replaceAll("{id}", currentId)
          .replaceAll("{season}", (nextSeasonIndex+1).toString())
          .replaceAll("{episode}", (nextEpisodeIndex+1).toString());

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
      await ViewContentInfo.updateLastWatch(
        source: args.source.name, 
        id: args.viewID, 
        seasonIndex: BigInt.from(nextSeasonIndex), 
        episodeIndex: BigInt.from(nextEpisodeIndex)
      );

      setState(() {
        args = WatchEmbedArguments(
          viewID: args.viewID,
          source: args.source,
          externalID: args.externalID,
          season: nextSeasonIndex,
          episode: nextEpisodeIndex
        );

        currentUrl = currentPrefillUrl.replaceAll("{id}", currentId)
          .replaceAll("{season}", (nextSeasonIndex+1).toString())
          .replaceAll("{episode}", (nextEpisodeIndex+1).toString());
        
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
                                isInspectable: false,
                                userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/115 Safari/537.36",
                                mediaPlaybackRequiresUserGesture: false,
                                allowsInlineMediaPlayback: true,
                                javaScriptEnabled: true,
                                domStorageEnabled: true,        
                                databaseEnabled: true,        
                                cacheEnabled: true,            
                                thirdPartyCookiesEnabled: true, 
                                allowsPictureInPictureMediaPlayback: true,
                                iframeAllowFullscreen: true,
                                
                              ),
                              initialUrlRequest: URLRequest(
                                url: WebUri(currentUrl),
                              ),
                              onWebViewCreated: (controller) {
                                webViewController = controller;
                              },
                              onLoadStart: (controller, url) async {
                                debugPrint("Page finished loading: $url");
                              },
                              onLoadStop: (controller, url) {
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
                                  for (var item in allowedNavigationOrigin){
                                    if (uri.host.endsWith(item) || !uri.startsWith("http")){ 
                                      return NavigationActionPolicy.ALLOW;
                                    } else {
                                      debugPrint("❌ Blocked navigation to: $uri");
                                      return NavigationActionPolicy.CANCEL;
                                    }
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
