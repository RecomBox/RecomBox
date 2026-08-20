import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/bulk_download.dart';
import 'package:recombox/src/global/dialogs/favorite/set_category_dialog.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/navigate_watch.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/view/dialogs/select_provider_dialog.dart';
import 'package:recombox/src/routes/view/widgets/episode_tile.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/get_download.dart';
import 'package:recombox/src/rust/method/favorite/is_in_category.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'dart:io';
import 'dart:async';
import 'package:recombox/src/global/widgets/title_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewScreenArguments {
  Source source;
  String id;

  ViewScreenArguments({
    required this.source,
    required this.id
  });
}

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});
  

  @override
  State<ViewScreen> createState() => _ViewState();
}


class _ViewState extends State<ViewScreen> with RouteAware {
  late ViewScreenArguments args;
  
  @override
  void initState() {
    super.initState();
    if (context.mounted){
      setState(() {
        isLoading = true;
      });
    }

    // Defer until after build context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;

      args = rawArgs is ViewScreenArguments
        ? rawArgs
        : ViewScreenArguments(
          source: Source.movies,
          id: "%2F53906%2Fspider-man",
        );

      debugPrint(args.toString());
      initViewContentInfo();
      
    });
  }


  @override
  void dispose() {
    _episodeScrollController.dispose();
    _seasonScrollController.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  List<int> currentEpisodeList = [];

  final _seasonScrollController = ScrollController();
  final _episodeScrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController(text: '');
  FocusNode searchFocus = FocusNode();
  bool isInFavorite = false;
  bool isError = false;
  bool showFloatingButton = false;
  bool bulkDownloadMode = false;
  bool bulkDownloadSelectAll = false;

  
  AppColorsScheme appColors = appColorsNotifier.value;

  ViewContentInfo? viewContentInfoResult;
  Timer? countdownTimer;
  List<int>? countdown;

  bool isLoading = false;
  int currentSeasonIndex = 0;
  int currentTabIndex = 0;
  var tabList = [
    {
      "icon": Icons.list,
      "label": "Episodes"
    },
    {
      "icon": Icons.panorama_rounded,
      "label": "Pictures"
    }
  ];

  
  Future<void> initViewContentInfo({bool fromCache=true}) async {
    
    if (!context.mounted) return;
    countdownTimer?.cancel();
    if (context.mounted){
      setState(() {
        isLoading = true;
      });
    }
    try{
      var data = await ViewContentInfo.get_(source: args.source.name, id: args.id, fromCache: fromCache, checkExpire: true);

      List<int> newEpData = [];
      for (var i = 0; i < data.episodes[currentSeasonIndex].toInt(); i++) {
        newEpData.add(i);
      }
      if (context.mounted){
        
        setState(() {
          viewContentInfoResult = data;
          currentEpisodeList = newEpData;
          currentSeasonIndex = (data.lastWatchSeasonIndex??BigInt.from(0)).toInt();
        });
      }
    }catch(e){
      debugPrint(e.toString());
      if (context.mounted){
        setState(() {
          isError = true;
        });
      }
      return;
    }
    
    if (viewContentInfoResult!.countdown > 0){
      countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => updateCountdown(),
      );
    }

    onFavoriteUpdate();

    bulkDownload = BulkDownload(
      source: args.source,
      id: args.id,
      seasonIndex: BigInt.from(currentSeasonIndex),
    );
    
    if (context.mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateCountdown() {
    // Convert seconds → milliseconds
    DateTime future = DateTime.fromMillisecondsSinceEpoch(
      viewContentInfoResult!.countdown,
      isUtc: true,
    );
    DateTime now = DateTime.now().toUtc();
    Duration diff = future.difference(now);

    if (context.mounted){
      setState(() {
        countdown = [
          diff.inDays,
          diff.inHours.remainder(24),
          diff.inMinutes.remainder(60),
          diff.inSeconds.remainder(60),
        ];
      });
    }

    // Reached the end
    if (diff.isNegative || diff.inSeconds <= 0) {
      countdownTimer?.cancel();
      initViewContentInfo(fromCache: false);
    }
  }

  Future<void> onFavoriteUpdate() async {
    bool inFavorite = await isInCategory(
        source: args.source.name, 
        id: args.id,
    );
    if (context.mounted){
      setState(() {
        isInFavorite = inFavorite;
      });
    }
  }

  void onSeasonChange(int index){
    bulkDownload = BulkDownload(
      source: args.source,
      id: args.id,
      seasonIndex: BigInt.from(index),
    );

    

    if (context.mounted){
      setState(() {
        bulkDownloadMode = false;
        bulkDownloadSelectAll = false;
        showFloatingButton = false;
        currentSeasonIndex = index;
      });
      
      onFilterChange();
    }


  }


  void onFilterChange() {
    if (_textEditingController.text.toLowerCase().isEmpty){
      List<int> newData = [];
      for (var i = 0; i < viewContentInfoResult!.episodes[currentSeasonIndex].toInt(); i++) {
        newData.add(i);
      }
      setState(() {
        currentEpisodeList = newData;
      });
    }else{
      List<int> newData = [];
      for (var i = 0; i < viewContentInfoResult!.episodes[currentSeasonIndex].toInt(); i++) {
        if (
          (i+1).toString().toLowerCase().contains(_textEditingController.text.toLowerCase()) ||
          i.toString().toLowerCase().contains(_textEditingController.text.toLowerCase()) ||
          ("Episode $i").toLowerCase().contains(_textEditingController.text.toLowerCase()) ||
          ("Episode ${i+1}").toLowerCase().contains(_textEditingController.text.toLowerCase())
        ){
          newData.add(i);
        }
      }
      setState(() {
        currentEpisodeList = newData;
      });
    }
  }


  void onRefresh(){
    initViewContentInfo(fromCache: false);
  }

  void onNavigateBack(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, "/home");
    }

  }


  Future<void> onNavigateDownload(BigInt seasonIndex, BigInt episodeIndex) async {
    final ctx = context;

    SelectPluginScreenArguments selectPluginArgs = SelectPluginScreenArguments(
      selectFileMode:  SelectFileMode.download,
      source: args.source,
      id: args.id,
      externalID: viewContentInfoResult!.externalId,
      title: viewContentInfoResult!.title,
      titleSecondary: viewContentInfoResult!.titleSecondary,
      season: seasonIndex,
      episode: episodeIndex
    );

    if (ctx.mounted){
      Navigator.pushNamed(
        ctx,
        '/select_plugin',
        arguments: selectPluginArgs,
      );
    }
  }

  Future<void> onPopupMenuSelectOption(int value) async {
    final ctx = context;

    switch (value) {
      case 0: 
        bulkDownload = BulkDownload(
          source: args.source,
          id: args.id,
          seasonIndex: BigInt.from(currentSeasonIndex),
        );
        if (ctx.mounted){
          setState(() {
            bulkDownloadMode = true;
            onSelectAllBulkDownload(false);
            showFloatingButton = true;
          });
        }
        break;
      default: break;
    }
    
  }

  Future<void> onSelectAllBulkDownload(bool state) async {
    final ctx = context;
    if (ctx.mounted){
      setState(() {
        bulkDownloadSelectAll = state;
      });
    }
    

    if (bulkDownloadSelectAll){
      for (var i = 0; i < viewContentInfoResult!.episodes[currentSeasonIndex].toInt(); i++) {
        
        DownloadItemValue? downloadItemValue = await getDownload(downloadItemKey: DownloadItemKey(
          source: args.source.name, 
          id: args.id, 
          seasonIndex: BigInt.from(currentSeasonIndex), 
          episodeIndex: BigInt.from(i)
        ));
        final isInDownload = downloadItemValue != null;

        if (!isInDownload){
          bulkDownload.add(BigInt.from(i), BulkDownloadValue());
        }
      }
    }else{
      bulkDownload.removeAll();
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: appColors.primary,
          child: Material(
            color: appColors.primary,
            child: Stack(
                children: [
                  if (isLoading) ...[
                    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
                      Positioned(top: 0, left: 0, right: 0, 
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,),
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
                              ),
                              IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                onPressed: onRefresh,
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  color: appColors.secondary,
                                ),
                              ),
                            ],
                          )
                        )
                      ),
                    if (!isError)
                    
                      Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: appColors.secondary,
                        )
                      ),

                    if (isError)
                      Container(
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
                  ],
                  if (!isLoading)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Stack(
                              children: [
                                Ink.image(
                                  image: viewContentInfoResult!.bannerUrl.isEmpty
                                    ? const AssetImage('assets/default_banner.png')
                                    : viewContentInfoResult!.bannerUrl.startsWith('http')
                                        ? NetworkImage(viewContentInfoResult!.bannerUrl)
                                        : FileImage(File(viewContentInfoResult!.bannerUrl)),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                                
                                Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    padding: EdgeInsets.only(bottom: 15),
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                            padding: EdgeInsets.only(left: 12),
                                            clipBehavior: Clip.hardEdge,
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                for (final contextual in viewContentInfoResult!.contextual)
                                                  Container(
                                                    margin: EdgeInsets.only(right: 8),
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: appColors.accentPrimary,
                                                    ),
                                                    child: Text(
                                                      contextual,
                                                      style: GoogleFonts.nunito(
                                                        fontWeight: FontWeight.normal,
                                                        color: appColors.textPrimary,
                                                        decoration: TextDecoration.none,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                              ],
                                            )),
                                      
                                      ],
                                    )),
                              
                                if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS))
                                  Positioned(top: 0, left: 0, right: 0, 
                                    child: Container(
                                      padding: EdgeInsets.only(left: 8, right: 8,),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          IconButton.filled(
                                            mouseCursor: SystemMouseCursors.click,
                                            onPressed: onNavigateBack,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.black.withAlpha(130)
                                            ),
                                            icon: Icon(
                                              Icons.arrow_back_rounded,
                                              color: appColors.secondary,
                                            ),
                                          ),
                                          IconButton(
                                            mouseCursor: SystemMouseCursors.click,
                                            onPressed: onRefresh,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.black.withAlpha(130)
                                            ),
                                            icon: Icon(
                                              Icons.refresh_rounded,
                                              color: appColors.secondary,
                                            ),
                                          ),
                                        ],
                                      )
                                    )
                                  ),

                                
                                

                              ]
                            ),
                          ),

                          InkWell(
                            onTap: (){
                              Clipboard.setData(ClipboardData(text: viewContentInfoResult!.title));
                              showToastWidget(
                                Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: appColors.tertiary,
                                    borderRadius: BorderRadius.circular(25)
                                  ),
                                  child: Text(
                                    "Title copied to clipboard",
                                    style: GoogleFonts.nunito(
                                      color: appColors.textPrimary,
                                      fontSize: 16
                                    ),
                                  ),
                                ),
                                position: ToastPosition.bottom,
                                dismissOtherToast: true,
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  viewContentInfoResult!.title,
                                  style: GoogleFonts.nunito(
                                    fontSize: 38,
                                    fontWeight: FontWeight(800),
                                    color: appColors.textPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),

                          // -> Button Container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () {
                                    navigateWatch(NavigateWatchArgs(
                                      context: context, 
                                      source: args.source, 
                                      provider: viewContentInfoResult?.selectedProvider,
                                      viewID: args.id, 
                                      externalID: viewContentInfoResult!.externalId, 
                                      title: viewContentInfoResult!.title, 
                                      titleSecondary: viewContentInfoResult!.titleSecondary, 
                                      seasonIndex: viewContentInfoResult!.lastWatchSeasonIndex??BigInt.from(0), 
                                      episodeIndex: viewContentInfoResult!.lastWatchEpisodeIndex??BigInt.from(0)
                                    ));
                                  },
                                  label: Text(
                                    (((viewContentInfoResult?.lastWatchSeasonIndex??BigInt.from(0)) > BigInt.from(0)) || ((viewContentInfoResult?.lastWatchEpisodeIndex??BigInt.from(0)) > BigInt.from(0)))
                                    ? SourceExtension.fromString(viewContentInfoResult?.source??"") == Source.tv
                                      ? "Continue S${((viewContentInfoResult?.lastWatchSeasonIndex??BigInt.from(0))+BigInt.from(1)).toString().padLeft(2, '0')}E${((viewContentInfoResult?.lastWatchEpisodeIndex??BigInt.from(0))+BigInt.from(1)).toString().padLeft(2, '0')}"
                                      : "Continue Watching"
                                    : "Watch Now",
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    enabledMouseCursor: SystemMouseCursors.click,
                                    backgroundColor: appColors.secondary,
                                    foregroundColor: appColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => SetCategoryDialog(
                                        source: args.source,
                                        itemId: args.id,
                                        onDone: onFavoriteUpdate,
                                      ),
                                    );

                                  },
                                  style: TextButton.styleFrom(
                                    enabledMouseCursor: SystemMouseCursors.click,
                                    backgroundColor: appColors.secondary,
                                    foregroundColor: appColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                  child: isInFavorite ? Icon(Icons.favorite_rounded) : Icon(Icons.favorite_outline_rounded),
                                ),
                                TextButton(
                                  onPressed: viewContentInfoResult!.trailerUrl.isEmpty ? null : () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: appColors.tertiary,
                                        title: Text(
                                          'Launch in external application?',
                                          style: GoogleFonts.nunito(
                                            color: appColors.textPrimary,
                                          )
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              'No',
                                              style: GoogleFonts.nunito(
                                                color: appColors.textPrimary,
                                                fontWeight: FontWeight(800),

                                              )
                                            ),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Yes',
                                              style: GoogleFonts.nunito(
                                                color: appColors.textPrimary,
                                                fontWeight: FontWeight(800),

                                              )
                                            ),
                                            onPressed: () {
                                              launchUrl(
                                                Uri.parse(viewContentInfoResult!.trailerUrl),
                                                mode: LaunchMode.platformDefault,
                                              )
                                                .then((value) => debugPrint(value.toString()))
                                                .catchError((error) => debugPrint(error.toString()));
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                      
                                  },
                                  style: TextButton.styleFrom(
                                    enabledMouseCursor: SystemMouseCursors.click,
                                    backgroundColor: appColors.secondary,
                                    foregroundColor: appColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                  child: Icon(Icons.video_library),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: appColors.tertiary,
                                        title: Text(
                                          'Launch in external application?',
                                          style: GoogleFonts.nunito(
                                            color: appColors.textPrimary,
                                          )
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              'No',
                                              style: GoogleFonts.nunito(
                                                color: appColors.textPrimary,
                                                fontWeight: FontWeight(800),

                                              )
                                            ),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Yes',
                                              style: GoogleFonts.nunito(
                                                color: appColors.textPrimary,
                                                fontWeight: FontWeight(800),

                                              )
                                            ),
                                            onPressed: () {
                                              launchUrl(
                                                Uri.parse(viewContentInfoResult!.url),
                                                mode: LaunchMode.platformDefault,
                                              )
                                                .then((value) => debugPrint(value.toString()))
                                                .catchError((error) => debugPrint(error.toString()));
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                      
                                  },
                                  style: TextButton.styleFrom(
                                    enabledMouseCursor: SystemMouseCursors.click,
                                    backgroundColor: appColors.secondary,
                                    foregroundColor: appColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                  child: Icon(Icons.launch),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SelectProviderDialog(
                                          source: args.source,
                                          viewID: args.id,
                                          onApply: (_) {
                                            initViewContentInfo();
                                          },
                                        );
                                      },
                                    );

                                      
                                  },
                                  style: TextButton.styleFrom(
                                    enabledMouseCursor: SystemMouseCursors.click,
                                    backgroundColor: appColors.secondary,
                                    foregroundColor: appColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                  child: Icon(Icons.settings_rounded),
                                )
                              ],
                            )
                          ),
                          // <-

                          // -> Title Secondary
                          if (viewContentInfoResult!.description.isNotEmpty)
                            InkWell(
                              onTap: (){
                                Clipboard.setData(ClipboardData(text: viewContentInfoResult!.titleSecondary));
                                showToastWidget(
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: appColors.tertiary,
                                      borderRadius: BorderRadius.circular(25)
                                    ),
                                    child: Text(
                                      "Title secondary copied to clipboard",
                                      style: GoogleFonts.nunito(
                                        color: appColors.textPrimary,
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                  position: ToastPosition.bottom,
                                  dismissOtherToast: true,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                width: double.infinity,
                                child: Text(
                                  "Title Secondary: ${viewContentInfoResult!.titleSecondary}",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: appColors.textPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            
                          // <-
                          
                          // -> Description
                          if (viewContentInfoResult!.description.isNotEmpty)
                            InkWell(
                              onTap: (){
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      decoration: BoxDecoration(
                                        color: appColors.tertiary,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5)
                                        ),
                                        border: BoxBorder.all(
                                          color: appColors.primary,
                                          width: 1
                                        )
                                      ),
                                      padding: EdgeInsets.all(15),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            spacing: 10,
                                            children: <Widget>[
                                              Text(
                                                "Description:",
                                                style: GoogleFonts.nunito(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight(800),
                                                  color: appColors.textPrimary,
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                              Text(
                                                viewContentInfoResult!.description,
                                                style: GoogleFonts.nunito(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: appColors.textPrimary,
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                        ),
                                      )
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                width: double.infinity,
                                child: Text(
                                  viewContentInfoResult!.description,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: appColors.textPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            
                          // <-
                          if (viewContentInfoResult!.description.isNotEmpty)
                            SizedBox(
                              height: 20,
                            ),

                          // -> Countdown
                          if (viewContentInfoResult!.countdown > 0)
                            Container(
                              padding: EdgeInsets.all(10),
                              color: appColors.tertiary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10,
                                children: [
                                  Text(
                                    "Countdown to next release:",
                                    style: GoogleFonts.nunito(
                                      fontSize: MediaQuery.of(context).size.width > 600 ? 32 : MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight(800),
                                      color: appColors.textPrimary,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: appColors.primary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        for (var entry in ["Days", "Hours", "Minutes", "Seconds"].asMap().entries)
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  (countdown?[entry.key] ?? 0).toString(), // This is mapped from new array after calculated.
                                                  style: GoogleFonts.nunito(
                                                    fontSize: MediaQuery.of(context).size.width > 600 ? 32 : MediaQuery.of(context).size.width * 0.05,
                                                    fontWeight: FontWeight(800),
                                                    color: appColors.textPrimary,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  entry.value,
                                                  style: GoogleFonts.nunito(
                                                    fontSize: MediaQuery.of(context).size.width > 600 ? 32 : MediaQuery.of(context).size.width * 0.05,
                                                    fontWeight: FontWeight(800),
                                                    color: appColors.textPrimary,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                  maxLines: 1,
                                                )
                                              ],
                                            )
                                            
                                          )
                                      ],
                                    )
                                  ),
                                ],
                              ),
                            ),
                          // <-

                          // -> SeasonList
                          if (viewContentInfoResult!.episodes.length > 1)
                            Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              height: 100,
                                child: Scrollbar(
                                  controller: _seasonScrollController,
                                  thickness: (Platform.isWindows ||
                                          Platform.isLinux ||
                                          Platform.isMacOS)
                                      ? null
                                      : 0,
                                  child: ListView.separated(
                                    controller: _seasonScrollController,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: viewContentInfoResult!.episodes.length,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        width: 130,
                                        child: TextButton(
                                          onPressed: () {
                                            onSeasonChange(index);
                                          },
                                          style: TextButton.styleFrom(
                                            enabledMouseCursor: SystemMouseCursors.click,
                                            side: BorderSide(color: appColors.tertiary, width: 2),
                                            backgroundColor: currentSeasonIndex == index ? appColors.tertiary : appColors.primary,
                                            foregroundColor: appColors.textPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            )
                                          ),
                                          
                                          child: Text("Season ${index + 1}"),
                                        )
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        width: 10,
                                      );
                                    },
                                  ),
                                
                                )
                            ),
                          // <-

                          // -> TabList
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              spacing: 2.5,
                              children: [
                                for (var entry in tabList.asMap().entries)
                                  ElevatedButton.icon(
                                    onPressed: (){
                                      if (context.mounted){
                                        setState(() {
                                          currentTabIndex = entry.key;
                                        });
                                      }
                                    },
                                    icon: Icon(entry.value["icon"] as IconData),
                                    label: Text(entry.value["label"] as String),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentTabIndex == entry.key ? appColors.accentPrimary : appColors.secondary,
                                      foregroundColor: currentTabIndex == entry.key ? appColors.secondary : appColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: currentTabIndex == entry.key 
                                          ? BorderRadius.circular(15)
                                          : entry.key == 0
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomLeft: Radius.circular(15)
                                              )
                                            : entry.key == tabList.length - 1
                                              ? BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                bottomRight: Radius.circular(15)
                                              )
                                              : BorderRadius.zero
                                      )
                                    ),
                                  )
                              ],
                            ),
                          ),
                          
                          // <-


                          IndexedStack(
                            index: currentTabIndex,
                            children: [
                              // -> Episodes
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                                color: appColors.strokePrimary
                                              )
                                            )
                                          ),
                                          width: double.infinity,
                                          height: 60,
                                          child: 
                                              GestureDetector(
                                                onTap: (){
                                                  searchFocus.requestFocus();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 10),
                                                  height: double.infinity,
                                                  child: Row(
                                                    spacing: 8,
                                                    children: [
                                                      Icon(
                                                        Icons.search,
                                                        color: appColors.textPrimary,
                                                      ),
                                                      Expanded(
                                                        child: TextField(
                                                          controller: _textEditingController,
                                                          onChanged: (_){
                                                            if (!context.mounted) return;
                                                            
                                                            onFilterChange();
                                                            
                                                          },
                                                          onSubmitted: (value){
                                                            if (!context.mounted) return;
                                                            
                                                            onFilterChange();
                                                            
                                                          },
                                                          cursorColor: appColors.textPrimary,
                                                          focusNode: searchFocus,
                                                          style: GoogleFonts.nunito(
                                                            fontSize: 24,
                                                            color: appColors.textPrimary,
                                                          ),
                                                          decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            hintText: "Search",
                                                            hintStyle: TextStyle(
                                                              color: appColors.textPrimary,
                                                            )
                                                          ),
                                                        )
                                                      )
                                                    ],
                                                  )
                                                )
                                              ),
                                          ),

                                      ),

                                      Container(
                                        padding: EdgeInsets.all(15),
                                        child: Theme(
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
                                                onTap: () => onPopupMenuSelectOption(0),
                                                child: MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: Text(
                                                    'Bulk Season Download',
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
                                      )
                                      
                                    ]
                                  ),

                                  if (bulkDownloadMode)
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 10,
                                        children: [
                                          IconButton(
                                            onPressed: ()=>onSelectAllBulkDownload(!bulkDownloadSelectAll), 
                                            icon: Icon(bulkDownloadSelectAll ? Icons.deselect_rounded : Icons.select_all_rounded),
                                            color: appColors.secondary,
                                            iconSize: 32,
                                          ),
                                          IconButton(
                                            onPressed: (){
                                              if (context.mounted){
                                                setState(() {
                                                  bulkDownloadMode = false;
                                                  showFloatingButton = false;
                                                });
                                              }
                                            }, 
                                            icon: Icon(Icons.close_rounded),
                                            color: Colors.red,
                                            iconSize: 32,
                                          )
                                        ],
                                      ),
                                    ),
                                  
                                  Container(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, showFloatingButton ? 80 : 10),
                                    child: Scrollbar(
                                      thickness: 0,
                                      controller: _episodeScrollController,
                                      
                                      child: ListView.separated(
                                        controller: _episodeScrollController,
                                        scrollDirection: Axis.vertical,
                                        itemCount: currentEpisodeList.length,
                                        itemBuilder: (current, index) {
                                            return Container(
                                              key: ValueKey('$currentSeasonIndex:$index:$bulkDownloadSelectAll'),
                                              color: ((viewContentInfoResult?.lastWatchSeasonIndex) == BigInt.from(currentSeasonIndex)) && ((viewContentInfoResult?.lastWatchEpisodeIndex) == BigInt.from(index))
                                                ? appColors.tertiary 
                                                : Colors.transparent,
                                              child: EpisodeTile(
                                                source: args.source,
                                                provider: viewContentInfoResult!.selectedProvider,
                                                viewID: args.id,
                                                externalID: viewContentInfoResult!.externalId,
                                                title: viewContentInfoResult!.title,
                                                titleSecondary: viewContentInfoResult!.titleSecondary,
                                                season: BigInt.from(currentSeasonIndex),
                                                episode: BigInt.from(currentEpisodeList[index]),
                                                onNavigateDownload: ()=>onNavigateDownload(BigInt.from(currentSeasonIndex), BigInt.from(index)),

                                                bulkDownloadMode: bulkDownloadMode,
                                                bulkDownloadSelectAll: bulkDownloadSelectAll
                                              )
                                            );
                                        }, 
                                        separatorBuilder: (current, index) {
                                          return Container(
                                            height: 1,
                                            color: appColors.strokePrimary,
                                          );
                                        },
                                        
                                      )
                                    )
                                  ),
                                ],
                              ),

                              // <- 
                              
                              // -> Pictures
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * 0.6,
                                padding: EdgeInsets.only(left: 10, right: 10),
                                alignment: Alignment.centerRight,
                                child: GridView.count(
                                  crossAxisCount: 2, // number of columns
                                  crossAxisSpacing: 10, // horizontal spacing
                                  mainAxisSpacing: 10, 
                                  children: [
                                    for (var pic in viewContentInfoResult!.pictures)
                                      Ink.image(
                                        width: 50,
                                        image: NetworkImage(pic),
                                      ),
                                  ],
                                )
                              )

                              // <-

                            ],
                          ),
                        ]

                        // <-
                      )
                    ),
                  
                    
                  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                    Positioned(top: 0, left: 0, right: 0, 
                      child: Container(
                        padding: EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            IconButton.filled(
                              mouseCursor: SystemMouseCursors.click,
                              onPressed: onNavigateBack,
                              style: IconButton.styleFrom(
                                backgroundColor: appColors.tertiary.withAlpha(125)
                              ),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: appColors.secondary,
                              ),
                            ),
                            IconButton(
                              mouseCursor: SystemMouseCursors.click,
                              onPressed: onRefresh,
                              style: IconButton.styleFrom(
                                backgroundColor: appColors.tertiary.withAlpha(125)
                              ),
                              icon: Icon(
                                Icons.refresh_rounded,
                                color: appColors.secondary,
                              ),
                            ),
                            Expanded(child: TitleBar())
                          ],
                        )
                      )
                    ),
                  
                ]
              ),
          ),
        ),
        floatingActionButton: 
          (showFloatingButton)
          ? SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, 
              children: [
                FloatingActionButton.extended(
                  mouseCursor: SystemMouseCursors.click,
                  heroTag: "Bulk Season Download", 
                  onPressed: () {
                    
                    if (bulkDownload.len() == 0){
                      showToastWidget(
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: appColors.tertiary,
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: Text(
                            'No items selected for bulk download.',
                            style: GoogleFonts.nunito(
                              color: appColors.textPrimary,
                              fontSize: 16
                            ),
                          ),
                        ),
                        position: ToastPosition.bottom,
                        dismissOtherToast: true,
                        
                      );
                      return;
                    }

                    final ctx = context;
                    SelectPluginScreenArguments selectPluginArgs = SelectPluginScreenArguments(
                      selectFileMode:  SelectFileMode.bulkDownload,
                      source: args.source,
                      id: args.id,
                      externalID: viewContentInfoResult!.externalId,
                      title: viewContentInfoResult!.title,
                      titleSecondary: viewContentInfoResult!.titleSecondary,
                      season: BigInt.from(0),
                      episode: BigInt.from(0)
                    );

                    if (ctx.mounted){
                      Navigator.pushNamed(
                        ctx,
                        '/select_plugin',
                        arguments: selectPluginArgs,
                      );
                    }
                  },
                  backgroundColor: appColors.accentSecondary,
                  icon: Icon(
                    Icons.link_rounded,
                    color: appColors.textPrimary,
                  ),
                  label: Text(
                    "Start Bulk Download",
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight(700),
                    ),
                  ),
                ),
              ],
            )
          ): null,
      )
    );
  }
}