import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/watch/dialogs/external_subtitles.dart';
import 'dart:math';

import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/subtitle_provider/get_installed_subtitles.dart';
import 'package:recombox/src/rust/method/subtitle_provider/remove_subtitles.dart';
class CommentDialog extends StatefulWidget {
  const CommentDialog({
    super.key,
    required this.watchScreenArgs,
  });

  final WatchScreenArguments watchScreenArgs;
  

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<SubtitleTrack> subtitleTrackList = [];
  Map<BigInt, GetInstalledSubtitlesData> externalSubtitleMap = {};

  String hostname = "https://recombox.pages.dev";
  String currentUrl = "";

  InAppWebViewController? webViewController;
  final GlobalKey _webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initWidget();
  }

  Future<void> initWidget() async {
    String url;
    if (widget.watchScreenArgs.source == Source.movies){
      url = "$hostname/${widget.watchScreenArgs.viewID}";
    }else{
      url = "$hostname/${widget.watchScreenArgs.viewID}/${widget.watchScreenArgs.season+BigInt.one}/${widget.watchScreenArgs.episode+BigInt.one}";
    }

    if (!mounted) return;
    setState(() {
      currentUrl = url;
    });
    debugPrint(currentUrl);
  }

  void onSubtitleTrackChange(SubtitleTrack track){
    
  }

  void onDisableSubtitle(){
    
  }

  void onClose(){
    try{
      webViewController = null;
    }catch(e){
      debugPrint(e.toString());
    }

    if (context.mounted){
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600)
            Expanded(
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  color: Colors.black.withAlpha(130),
                ),
              )
            ),
          Container(
            width: min(600, MediaQuery.of(context).size.width),
            decoration: BoxDecoration(
              color: appColors.primary,
              border: Border(
                left: MediaQuery.of(context).size.width >= 600 
                  ? BorderSide(
                    width: 1,
                    color: appColors.strokePrimary
                  )
                  : BorderSide.none
              )
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: appColors.strokePrimary
                      )
                    )
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        iconSize: 32,
                        color: appColors.secondary,
                        onPressed: onClose,
                        icon: const Icon(Icons.close)
                      ),
                      Expanded(
                        child: Text(
                          "Comments",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight(600),
                          )
                        )
                      ),
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        iconSize: 32,
                        color: appColors.secondary,
                        onPressed: (){
                          webViewController?.goBack();
                        },
                        icon: const Icon(Icons.chevron_left_rounded)
                      ),
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        iconSize: 32,
                        color: appColors.secondary,
                        onPressed: (){
                          webViewController?.goForward();
                        },
                        icon: const Icon(Icons.chevron_right_rounded)
                      ),
                      IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        iconSize: 32,
                        color: appColors.secondary,
                        onPressed: (){
                          webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));
                        },
                        icon: const Icon(Icons.refresh_rounded)
                      ),
                    ],
                  )
                ),
                
                Expanded(
                  // Don't create the webview until the URL is ready, so it
                  // starts on the real page instead of an empty one.
                  child: currentUrl.isEmpty
                    ? const SizedBox.shrink()
                    : LayoutBuilder(
                    key: _webViewKey,
                    builder: (context, constraints) {
                      return InAppWebView(
                        initialSettings: InAppWebViewSettings(
                          isInspectable: false,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          javaScriptEnabled: true,
                          domStorageEnabled: true,        
                          databaseEnabled: true,        
                          cacheEnabled: true,            
                          thirdPartyCookiesEnabled: true, 
                          allowsPictureInPictureMediaPlayback: true,
                          iframeAllowFullscreen: true,
                          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                          
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
                          
                        },
                        onExitFullscreen: (controller) async {
                          
                          
                        },

                      );
                    },
                  ),
                )
                

              ],
            )
          
          )
        ]
      )
    );
  }
}