import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/home/widgets/content_section.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/routes/watch/dialogs/audio_track_control.dart';
import 'package:recombox/src/routes/watch/dialogs/subtitle_track_control%20.dart';
import 'package:recombox/src/rust/method/get_settings.dart';
import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';
import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:media_kit_video/media_kit_video.dart';


import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:recombox/src/rust/method/torrent_provider/free_torrent_handle.dart';
import 'package:snowflaker/snowflaker.dart';
import 'package:window_manager/window_manager.dart';


class WatchScreenArguments {
  String viewID;
  Source source;
  String torrentSource;
  String mimeType;
  BigInt fileID;
  BigInt season;
  BigInt episode;

  WatchScreenArguments({
    required this.viewID,
    required this.source,
    required this.torrentSource,
    required this.mimeType,
    required this.fileID,
    required this.season,
    required this.episode
  });
}




class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchState();
}

class _WatchState extends State<WatchScreen> {

  bool isLoading = false;

	List<FeaturedContentInfo> featuredContentList = [];
	Map<Source, List<TrendingContentInfo>> trendingContentMap = {};

  AppColorsScheme appColors = appColorsNotifier.value;

  WatchScreenArguments? args;

  late final player = Player();
  late final controller = VideoController(
    player,
    configuration: VideoControllerConfiguration(
      enableHardwareAcceleration: true
    )
  );
  
  

  @override
  void initState() {
    super.initState();
    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        args = rawArgs is  WatchScreenArguments
            ? rawArgs
            :  WatchScreenArguments(
              viewID: "72673844%20loki-test",
              source: Source.tv,
              torrentSource: "magnet:?xt=urn:btih:b130fefafb59f52390650a758b5c2810d4333e5c&dn=%5BToonsHub%5D%20One%20Piece%20S01E01-16%201080p%20NF%20WEB-DL%20MULTi%20AAC2.0%20H.264%20%28REMASTERED%2C%20Multi-Audio%2C%20Multi-Subs%29%20%5BBATCH%5D&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce",
              mimeType: "video/mp4",
              fileID: BigInt.from(0),
              season: BigInt.from(1),
              episode: BigInt.from(1)
            );
      });
      debugPrint(args.toString());
      initWatch();
    });

    
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }


  BigInt handleID = BigInt.from(0);

  Future<void> initWatch({bool fromCache=true}) async {
    if (!context.mounted) return;

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try{
      
      final snowflaker = Snowflaker(workerId: 1, datacenterId: 1);
      setState(() {
        handleID = BigInt.from(snowflaker.nextId().toInt());
      });
      
      final settings = await getSettings();

      final port = settings.port;
      debugPrint(port.toString());
      final uri = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: port,
        path: 'stream_video',
        queryParameters: {
          'handle_id': handleID.toString(),
          'torrent_source': args!.torrentSource,
          'mime_type': args!.mimeType,
          'file_id': args!.fileID.toString(),
          'view_id': args!.viewID,
          'season': args!.season.toString(),
          'episode': args!.episode.toString()
        },
      );

      debugPrint(uri.toString());

      player.open(Media(uri.toString()));
      // player.open(Media("https://github.com/ietf-wg-cellar/matroska-test-files/raw/refs/heads/master/test_files/test5.mkv"));
      
      debugPrint(handleID.toString());
    }catch(e){
      debugPrint(e.toString());
    }

    if (context.mounted){
      setState(() {
        isLoading = false;
      });
    }
    
  }


  Future<void> onNavigateBack() async {
    final ctx = context;
    debugPrint(isFullscreen(ctx).toString());

    // ->Reset Screen on Mobile
    await exitFullscreen(context);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // <-

    // -> Reset Screen on Desktop
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setFullScreen(false);
    }
    // <-


    try{
      await freeTorrentHandle(handleId: handleID);
    }catch(e){
      debugPrint(e.toString());
    }

    if (!ctx.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      ctx,
      "/view", 
      ModalRoute.withName("/"),
      arguments: ViewScreenArguments(
        source: args!.source, 
        id: args!.viewID
      )
    );
    
    
  }

  @override
  Widget build(BuildContext context) {
    // Listen to audio tracks
    player.stream.tracks.listen((tracks) {
      for (final a in tracks.audio) {
        debugPrint('Audio track: ${a.id} ${a.language} ${a.codec}');
      }
    });

    player.stream.tracks.listen((tracks) {
      // Print all subtitle tracks
      for (final subtitle in tracks.subtitle) {
        debugPrint('Subtitle: id=${subtitle.id}, title=${subtitle.title}, language=${subtitle.language}');
      }
    });

  List<Widget> topButtonBar = [
    IconButton(
      mouseCursor: SystemMouseCursors.click,
      iconSize: 32,
      color: appColors.secondary,
      onPressed: onNavigateBack,
      icon: Icon(
        Icons.arrow_back_rounded,
        color: appColors.secondary,
      ),
    ),
    const Spacer(),

    IconButton(
      mouseCursor: SystemMouseCursors.click,
      iconSize: 32,
      color: appColors.secondary,
      onPressed: (){
        if (context.mounted){
          showDialog(
            context: context, 
            builder: (_)=>SubtitleTrackControlDialog(
              player: player 
            )
          );
        }
      } ,
      icon: Icon(Icons.subtitles_rounded)
    ),

    const SizedBox(width: 10),
    
    IconButton(
      mouseCursor: SystemMouseCursors.click,
      iconSize: 32,
      color: appColors.secondary,
      onPressed: (){
        if (context.mounted){
          showDialog(
            context: context, 
            builder: (_)=>AudioTrackControlDialog(
              player: player 
            )
          );
        }
      } ,
      icon: Icon(Icons.audio_file_rounded)
    ),
  
  ];

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                TitleBar(),

              Expanded(
                // Use [Video] widget to display video output.
                child: Stack(
                  children: [
                    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                      MaterialDesktopVideoControlsTheme(
                        fullscreen: MaterialDesktopVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          buttonBarButtonSize: 32,
                          buttonBarButtonColor: appColors.secondary,
                          topButtonBar: topButtonBar,
                        ),
                        normal: MaterialDesktopVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          topButtonBar: topButtonBar,
                          
                        ),
                        
                        child: Scaffold(
                          body: Video(
                            controller: controller,
                          ),
                        ),
                      ),
                    
                    if (!(Platform.isLinux || Platform.isWindows || Platform.isMacOS))
                      MaterialVideoControlsTheme(
                        fullscreen: MaterialVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          topButtonBar: topButtonBar,
                        ),
                        normal: MaterialVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          topButtonBar: topButtonBar,
                          
                        ),
                        
                        child: Scaffold(
                          body: Video(
                            controller: controller,
                          ),
                        ),
                      ),
                    
                  ],
                ),
              )
            ],
          )
        )
      )
    );
  }
}


// itemBuilder: (ctx) => player.state.tracks.audio
//           .where((track) => track.id != 'auto' && track.id != 'no' && track.codec != null)
//           .map((track) => PopupMenuItem<AudioTrack>(
//                 value: track,
//                 child: Text("Audio: ${track.id} | ${track.language ?? 'Default'}"),
//               ))
//           .toList(),


    