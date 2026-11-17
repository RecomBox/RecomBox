import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:recombox/src/routes/watch/watch.dart';
import 'package:recombox/src/rust/method/subtitle_provider/get_installed_subtitles.dart';
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

  Timer? _cookieSaveTimer;

  @override
  void initState() {
    super.initState();
    initWidget();
  }

  @override
  void dispose() {
    _cookieSaveTimer?.cancel();
    saveCookies();
    super.dispose();
  }

  // -> Cookie persistence (Linux)
  // The Linux webview (WPE WebKit) keeps cookies in memory only, so the Disqus
  // login is lost on restart. Save the relevant cookies to a local file (only
  // readable by the current user, never sent anywhere) and restore them before
  // the webview is created.

  bool get _persistCookies => Platform.isLinux;

  bool _isCommentCookie(String? domain) {
    final d = domain ?? "";
    return d.contains("disqus") || d.contains("disq.us") || d.contains("recombox.pages.dev");
  }

  Future<File> _cookieFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(path.join(dir.path, "comment_cookies.json"));
  }

  Future<void> saveCookies() async {
    if (!_persistCookies) return;
    try {
      final cookies = await CookieManager.instance().getAllCookies();
      final data = cookies
        .where((c) => _isCommentCookie(c.domain))
        .map((c) => {
          "name": c.name,
          "value": c.value,
          "domain": c.domain,
          "path": c.path ?? "/",
          "expiresDate": c.expiresDate,
          "isSecure": c.isSecure,
          "isHttpOnly": c.isHttpOnly,
          "sameSite": c.sameSite?.toNativeValue(),
        })
        .toList();
      if (data.isEmpty) return; // Don't wipe a saved login with an empty jar.
      final file = await _cookieFile();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(data));
      // Restrict to the current user only (like browser cookie stores).
      await Process.run("chmod", ["600", file.path]);
    } catch (e) {
      debugPrint("Failed to save comment cookies: $e");
    }
  }

  Future<void> restoreCookies() async {
    if (!_persistCookies) return;
    try {
      final file = await _cookieFile();
      if (!await file.exists()) return;
      final List<dynamic> data = jsonDecode(await file.readAsString());
      final now = DateTime.now().millisecondsSinceEpoch;
      final cookieManager = CookieManager.instance();
      for (final c in data) {
        final int? expiresDate = c["expiresDate"];
        if (expiresDate != null && expiresDate < now) continue;
        final String domain = c["domain"] ?? "";
        if (domain.isEmpty) continue;
        final String cookiePath = c["path"] ?? "/";
        final host = domain.startsWith(".") ? domain.substring(1) : domain;
        await cookieManager.setCookie(
          url: WebUri("https://$host$cookiePath"),
          name: c["name"],
          value: c["value"],
          domain: domain,
          path: cookiePath,
          expiresDate: expiresDate,
          isSecure: c["isSecure"],
          isHttpOnly: c["isHttpOnly"],
          sameSite: HTTPCookieSameSitePolicy.fromNativeValue(c["sameSite"]),
        );
      }
    } catch (e) {
      debugPrint("Failed to restore comment cookies: $e");
    }
  }
  // <-

  Future<void> initWidget() async {
    await restoreCookies();
    if (_persistCookies) {
      // Login happens inside the Disqus iframe/popup, which doesn't fire
      // page load events here, so save periodically while the dialog is open.
      _cookieSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) => saveCookies());
    }

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
                          saveCookies();
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