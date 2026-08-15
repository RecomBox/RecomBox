// import 'package:flutter/material.dart';
// import 'package:recombox/src/global/webview/webview_desktop.dart';
// import 'package:webview_cef/webview_cef.dart';
// import 'package:flutter/foundation.dart';

// class WebView extends StatefulWidget {
//   const WebView({
//     super.key,
//     required this.url,
//   });

//   final String url;

//   @override
//   State<WebView> createState() => _WebViewState();
// }

// class _WebViewState extends State<WebView> {

//   Widget? currentWebView;

//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   void init() async {
//     if (defaultTargetPlatform == TargetPlatform.windows ||
//     defaultTargetPlatform == TargetPlatform.macOS ||
//     defaultTargetPlatform == TargetPlatform.linux) {
//       currentWebView = WebViewDesktop(
//         url: widget.url
//       );
//     }
    
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: (currentWebView != null) 
//         ? currentWebView!
//         : SizedBox(),
//     );
//   }
// }