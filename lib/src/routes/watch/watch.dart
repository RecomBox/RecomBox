
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/navigate_watch.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/routes/watch/dialogs/audio_track_control.dart';
import 'package:recombox/src/routes/watch/dialogs/subtitle_track_control.dart';
import 'package:recombox/src/rust/method/current_watch.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_download.dart';
import 'package:recombox/src/rust/method/download_provider/get_download_status.dart';
import 'package:recombox/src/rust/method/settings/get_settings.dart';
import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';
import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;

import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'package:recombox/src/rust/method/torrent_provider/free_torrent_handle.dart';
import 'package:recombox/src/rust/method/watch_state.dart';
import 'package:recombox/src/rust/method/watch_state/get_watch_state.dart';
import 'package:recombox/src/rust/method/watch_state/set_watch_state.dart';
import 'package:recombox/src/rust/utils/torrent_provider/torrent_handle.dart';
import 'package:window_manager/window_manager.dart';


class WatchScreenArguments {
  SelectFileMode selectFileMode;
  Source source;
  String viewID;
  ExternalID externalID;
  String title;
  String titleSecondary;
  String torrentSource;
  String mimeType;
  BigInt fileID;
  BigInt season;
  BigInt episode;

  WatchScreenArguments({
    required this.selectFileMode,
    required this.source,
    required this.viewID,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
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
  TorrentHandleMode torrentHandleMode = TorrentHandleMode.watch;

  late final player = Player();
  late final controller = VideoController(
    player,
    configuration: VideoControllerConfiguration(
      enableHardwareAcceleration: true
    )
  );

  StreamSubscription? _positionSubscription;
  StreamSubscription? _errorSubscription;

  final List<BoxFit> boxFitList = [
    BoxFit.contain,
    BoxFit.cover,
    BoxFit.fill,
    BoxFit.fitWidth,
    BoxFit.fitHeight,
    BoxFit.scaleDown,
  ];
  int currentBoxFitIndex = 0;
  

  @override

  void initState() {
    super.initState();
    _errorSubscription = player.stream.error.listen((error) {
      debugPrint("Player error: ${error.toString()} - Retrying again after 3s...");
      final index = player.state.playlist.index;
      if (index >= 0) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted){
            player.open(player.state.playlist.medias[index]);
          }
        });
      }
    });

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      if (context.mounted){

        setState(() {
          args = rawArgs is  WatchScreenArguments
              ? rawArgs
              :  WatchScreenArguments(
                selectFileMode: SelectFileMode.watch,
                viewID: "72673844%20loki-test",
                externalID: ExternalID(imdb: "tt7468056"),
                source: Source.movies,
                title: "One Piece",
                titleSecondary: "One Piece",
                torrentSource: "magnet:?xt=urn:btih:b130fefafb59f52390650a758b5c2810d4333e5c&dn=%5BToonsHub%5D%20One%20Piece%20S01E01-16%201080p%20NF%20WEB-DL%20MULTi%20AAC2.0%20H.264%20%28REMASTERED%2C%20Multi-Audio%2C%20Multi-Subs%29%20%5BBATCH%5D&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce",
                mimeType: "video/mp4",
                fileID: BigInt.from(0),
                season: BigInt.from(1),
                episode: BigInt.from(1)
              );
        });
        debugPrint(args.toString());

        // if (context.mounted){
        //   showDialog(
        //     context: context, 
        //     builder: (_)=>ExternalSubtitleDialog(
        //       watchScreenArgs: args!,
        //       onClose: (){},
        //     )
        //   );
        // }

        initWatch();
      }
    });

    
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _positionSubscription?.cancel();
    player.dispose();
    
    try{
      if (torrentHandleMode == TorrentHandleMode.watch) {
        freeTorrentHandle(
          torrentHandleMode: torrentHandleMode,
          torrentSource: args!.torrentSource,
          deleteFiles: true,
          checkCacheSizeBeforeDelete: true
        );
      }
      
    }catch(e){
      debugPrint(e.toString());
    }
    super.dispose();
  }


  Future<void> initWatch({bool fromCache=true}) async {
    final ctx = context;
    if (!ctx.mounted) return;

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try{
      try{
        debugPrint(args!.season.toString());
        debugPrint(args!.episode.toString());
        await ViewContentInfo.updateLastWatch(
          source: args!.source.name, 
          id: args!.viewID, 
          seasonIndex: args!.season, 
          episodeIndex: args!.episode
        );
      }catch(e){
        debugPrint("[Failed to update Last Watch]${e.toString()}");
      }
      
      final settings = await getSettings();

      final port = settings.port;
      

      final currentDownloadStatus = await getDownloadStatus(downloadItemKey: DownloadItemKey(
        source: args!.source.name, 
        id: args!.viewID, 
        seasonIndex: args!.season, 
        episodeIndex: args!.episode
      ));
      final downloadInfo = await getDownload(downloadItemKey: DownloadItemKey(
        source: args!.source.name, 
        id: args!.viewID, 
        seasonIndex: args!.season, 
        episodeIndex: args!.episode
      ));

      debugPrint(currentDownloadStatus.toString());

      var useLocal = false;
      torrentHandleMode = TorrentHandleMode.watch;
      
      if (currentDownloadStatus != null && downloadInfo != null){
        if (!currentDownloadStatus.paused){
          torrentHandleMode = TorrentHandleMode.download;
        }

        if (currentDownloadStatus.done){
          final downloadItemInfo = await getDownload(downloadItemKey: DownloadItemKey(
            source: args!.source.name, 
            id: args!.viewID, 
            seasonIndex: args!.season, 
            episodeIndex: args!.episode
          ));
          if (downloadItemInfo != null){
            torrentHandleMode = TorrentHandleMode.download;
            final filePath = path.join(
              settings.paths.appSupportDir,
              "download",
              "data",
              downloadItemInfo.filePath
            );

            debugPrint(args!.viewID);

            debugPrint(Uri.file(filePath).toString());
            useLocal = true;

            if (ctx.mounted){
              player.open(Media(Uri.file(filePath).toString()), play: true);
            }
          }
        }
      }
      
      
      
      if (!useLocal){
        final uri = Uri(
          scheme: 'http',
          host: '127.0.0.1',
          port: port,
          path: 'stream_video',
          queryParameters: {
            'torrent_handle_mode': torrentHandleMode.name,
            'torrent_source': args!.torrentSource,
            'mime_type': args!.mimeType,
            'file_id': args!.fileID.toString(),
            'view_id': args!.viewID,
            'season': args!.season.toString(),
            'episode': args!.episode.toString()
          },
        );

        await setCurrentWatchTorrent(torrentSource: args!.torrentSource);

        
        if (ctx.mounted){
          player.open(Media(uri.toString()), play: true);
        }
      }

      if (ctx.mounted){
        setState(() {
          isLoading = false;
        });
      }
      
      await initWatchState();
      initPlayerListener();
    }catch(e){
      debugPrint(e.toString());
    }

    if (ctx.mounted){
      setState(() {
        isLoading = false;
      });
    }



    
  }

  Future<void> initWatchState() async {
    try {
      final watchState = await getWatchState(
        watchStateKey: WatchStateKey(
            source: args!.source.name, 
            id: args!.viewID, 
            seasonIndex: args!.season, 
            episodeIndex: args!.episode
          ), 
      );

      debugPrint("WT ${watchState?.position.toString()}");

      if (watchState != null ) {

        await player.stream.buffering.firstWhere((isBuffering) => isBuffering == false);
        await player.stream.position.firstWhere((d) => d.inMilliseconds > 0);
        
        await player.seek(Duration(milliseconds: (watchState.position??BigInt.from(0)).toInt()));
      }
    }catch(e){
      debugPrint(e.toString());
    }
      
  }

  void initPlayerListener() async {
    _positionSubscription = player.stream.position
    .distinct((prev, next) {
      // Define your delay right here
      const int delay = 3; 
      
      // Calculate which 'slot' the time falls into
      final int prevSlot = prev.inSeconds ~/ delay;
      final int nextSlot = next.inSeconds ~/ delay;
      
      // If the slots are identical, the 'distinct' check is true (skip)
      return prevSlot == nextSlot;
    })
    .listen((pos) async {

      try{
        if (pos.inSeconds > 0){
          await setWatchState(
            watchStateKey: WatchStateKey(
              source: args!.source.name, 
              id: args!.viewID, 
              seasonIndex: args!.season, 
              episodeIndex: args!.episode
            ), 
            watchStateValue: WatchStateValue(
              position: BigInt.from(pos.inMilliseconds)
            )
          );
        }
        
      }catch(e){
        debugPrint(e.toString());
      }
    });
  }

  void onToggleFitBox() {
    if (context.mounted){
      setState(() {
        currentBoxFitIndex = (currentBoxFitIndex + 1) % boxFitList.length;
        
      });
      try{
        showToastWidget(
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: appColors.tertiary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Text(
              'BoxFit: ${boxFitList[currentBoxFitIndex].name} ${currentBoxFitIndex == 0 ? "(Default)" : ""}',
              style: GoogleFonts.nunito(
                color: appColors.textPrimary,
                fontSize: 16
              ),
            ),
          ),
          position: ToastPosition.bottom,
          dismissOtherToast: true,
          
        );
      }catch(e){
        debugPrint(e.toString());
      }
      
    }
    
  }

  Future<void> onSelectOption(int value) async {
      if (!context.mounted) return;
      switch (value) {
        case 0: 
          final ctx = context;
          await onNavigateCleanUp();
          if (!ctx.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            ctx, 
            "/select_plugin",
            (route) => false,
            arguments: SelectPluginScreenArguments(
              selectFileMode: args!.selectFileMode,
              source: args!.source, 
              id: args!.viewID, 
              externalID: args!.externalID, 
              title: args!.title, 
              titleSecondary: args!.titleSecondary, 
              season: args!.season, 
              episode: args!.episode
            )
          );
          break;
        default: break;
        
      }
  }

  Future<void> onNavigateCleanUp() async {
    try{

      
      final ctx = context;
      debugPrint(isFullscreen(ctx).toString());

      // ->Reset Screen on Mobile
      await exitFullscreen(ctx);
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
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> seekPosition(int seconds) async {

    final currentPosition = player.state.position;
    
    final newPosition = currentPosition + Duration(seconds: seconds);
    
    await player.seek(newPosition);
  }

  void onWatchNext() async {
    final ctx = context;
    final viewContentInfoResult = await ViewContentInfo.get_(
      source: args!.source.name,
      id: args!.viewID,
      fromCache: true,
      checkExpire: false
    );

    final episodeList = viewContentInfoResult.episodes;

    bool availableNext = false;

    int nextSeasonIndex = args!.season.toInt();
    int nextEpisodeIndex = args!.episode.toInt() + 1;

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

    await onNavigateCleanUp();

    if (availableNext && ctx.mounted){
      navigateWatch(NavigateWatchArgs(
        context: ctx, 
        provider: 0,
        source: args!.source, 
        viewID: args!.viewID, 
        externalID: args!.externalID, 
        title: args!.title, 
        titleSecondary: args!.titleSecondary, 
        seasonIndex: BigInt.from(nextSeasonIndex), 
        episodeIndex: BigInt.from(nextEpisodeIndex)
      ));
    }
    
  }

  void onWatchPrevious() async {
    final ctx = context;

    bool availableNext = false;

    int nextSeasonIndex = args!.season.toInt();
    int nextEpisodeIndex = args!.episode.toInt() - 1;

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

    await onNavigateCleanUp();
    if (availableNext && ctx.mounted){
      
      navigateWatch(NavigateWatchArgs(
        context: ctx, 
        provider: 0,
        source: args!.source, 
        viewID: args!.viewID, 
        externalID: args!.externalID, 
        title: args!.title, 
        titleSecondary: args!.titleSecondary, 
        seasonIndex: BigInt.from(nextSeasonIndex), 
        episodeIndex: BigInt.from(nextEpisodeIndex)
      ));
    }
    
  }

  

  @override
  Widget build(BuildContext context) {

    List<Widget> topButtonBar = [
      IconButton(
        mouseCursor: SystemMouseCursors.click,
        iconSize: 32,
        color: appColors.secondary,
        onPressed: ()async{
          if (context.mounted){
            final ctx = context;
            await onNavigateCleanUp();

            if (!ctx.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              ctx,
              "/view", 
              (route) => false,
              arguments: ViewScreenArguments(
                source: args!.source, 
                id: args!.viewID
              )
            );
          }

        },
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
                watchScreenArgs: args!,
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

      const SizedBox(width: 10),

      Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            color: appColors.tertiary,
            textStyle: GoogleFonts.nunito(
              fontSize: 18,
              color: appColors.textPrimary,
              fontWeight: FontWeight(600)
            ),
          ),
        ),
        child: PopupMenuButton<int>(
          icon: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              Icons.more_vert_rounded,
              color: appColors.secondary,
            ),
          ),
          tooltip: "Show options",
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<int>(
              onTap: () => onSelectOption(0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  'Change Plugin',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: appColors.textPrimary,
                    fontWeight: FontWeight(600)
                  ),
                ),
              )
              
            ),
          ],
          
        ),
      )


    ];

    List<Widget> bottomButtonBar = [
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ...[
        MaterialDesktopVolumeButton(),
        const SizedBox(width: 10),
      ],
      
      MaterialPositionIndicator(),

      const Spacer(),

      IconButton(
        mouseCursor: SystemMouseCursors.click,
        iconSize: 32,
        color: appColors.secondary,
        onPressed: onToggleFitBox,
        icon: Icon(Icons.fit_screen_outlined)
      ),
      const SizedBox(width: 10),

      MaterialFullscreenButton(),
      
      
    
    ];

    List<Widget> primaryButtonBar = [

      IconButton(
        mouseCursor: SystemMouseCursors.click,
        iconSize: 32,
        color: appColors.secondary,
        onPressed: onWatchPrevious,
        icon: Icon(Icons.skip_previous_rounded)
      ),
      const SizedBox(width: 10),
      

      const Spacer(),
      IconButton(
        mouseCursor: SystemMouseCursors.click,
        iconSize: 32,
        color: appColors.secondary,
        onPressed: ()=> seekPosition(-10),
        icon: Icon(Icons.replay_10_rounded),
      ),
      const Spacer(),

      
      MaterialPlayOrPauseButton(),
      const Spacer(),
    
      IconButton(
        mouseCursor: SystemMouseCursors.click,
        iconSize: 32,
        color: appColors.secondary,
        onPressed: ()=> seekPosition(10),
        icon: Icon(Icons.forward_10_rounded),
      ),

      const Spacer(),

      IconButton(
        mouseCursor: SystemMouseCursors.click,
        iconSize: 32,
        color: appColors.secondary,
        onPressed: onWatchNext,
        icon: Icon(Icons.skip_next_rounded)
      ),
      const SizedBox(width: 10),
      
      
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
                          topButtonBar: topButtonBar,
                          primaryButtonBar: primaryButtonBar,
                          bottomButtonBar: bottomButtonBar,
                          hideMouseOnControlsRemoval: true,
                        ),
                        normal: MaterialDesktopVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          topButtonBar: topButtonBar,
                          primaryButtonBar: primaryButtonBar,
                          bottomButtonBar: bottomButtonBar,
                          hideMouseOnControlsRemoval: true,
                          
                        ),
                        
                        child: Scaffold(
                          body: Video(
                            controller: controller,
                            fit: boxFitList[currentBoxFitIndex],
                          ),
                        ),
                      ),
                    
                    if (!(Platform.isLinux || Platform.isWindows || Platform.isMacOS))
                      MaterialVideoControlsTheme(
                        fullscreen: MaterialVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          topButtonBar: topButtonBar,
                          primaryButtonBar: primaryButtonBar,
                          bottomButtonBar: bottomButtonBar,
                          
                        ),
                        normal: MaterialVideoControlsThemeData(
                          padding: const EdgeInsets.all(25),
                          topButtonBar: topButtonBar,
                          primaryButtonBar: primaryButtonBar,
                          bottomButtonBar: bottomButtonBar,
                          
                        ),
                        
                        child: Scaffold(
                          body: Video(
                            controller: controller,
                            fit: boxFitList[currentBoxFitIndex],
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
