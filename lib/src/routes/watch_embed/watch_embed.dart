// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:recombox/src/global/app_color.dart';
// import 'package:recombox/src/global/types.dart';
// import 'package:recombox/src/global/webview/webview.dart';
// import 'package:recombox/src/routes/home/widgets/content_section.dart';
// import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';
// import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';
// import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_horizontal.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'dart:math';

// import 'package:flutter/foundation.dart'; // for Factory
// import 'package:flutter/gestures.dart';   // for gesture recognizers



// class WatchEmbedScreen extends StatefulWidget {
//   const WatchEmbedScreen({super.key});

//   @override
//   State<WatchEmbedScreen> createState() => _WatchEmbedState();
// }

// class _WatchEmbedState extends State<WatchEmbedScreen> {

//   bool isLoading = false;
//   bool isError = false;

// 	List<FeaturedContentInfo> featuredContentList = [];
// 	Map<Source, List<TrendingContentInfo>> trendingContentMap = {};

//   AppColorsScheme appColors = appColorsNotifier.value;

  

//   final FocusNode _focusNode = FocusNode();


//   @override
//   void initState() {
//     super.initState();


//     _focusNode.requestFocus();
//     init();
//   }



  
//   Future<void> init({bool fromCache=true}) async {
   
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Material(
//         color: Colors.transparent,
//         child: Row(
//           children: [
//             ElevatedButton(
//               onPressed: () {
                
//               },
//               child: const Text('Back'),
//             ),
//             Container(
//               width: 600,
//               height: 800,
//               color: Colors.green,
//               child: WebView(
//                 url: 'https://player.vidlove.cc/embed/movie/27205?primarycolor=ff4d6d&secondarycolor=c49de8',
//               )
              
//             )
          
            
//           ],
//         )
//       )
//     );
//   }
// }
