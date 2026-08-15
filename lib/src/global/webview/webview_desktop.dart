// import 'package:flutter/material.dart';
// import 'package:webview_cef/webview_cef.dart';

// class WebViewDesktop extends StatefulWidget {
//   const WebViewDesktop({
//     super.key,
//     required this.url,
//   });
//   final String url;

//   @override
//   State<WebViewDesktop> createState() => _WebViewDesktopState();
// }

// class _WebViewDesktopState extends State<WebViewDesktop> {

//   final controller = WebviewManager().createWebView();

//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   void init() async {
//     controller.initialize(widget.url);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: controller,
//       builder: (_, ready, __) =>
//         ready ? controller.webviewWidget : controller.loadingWidget,
//     );
    
//   }
// }