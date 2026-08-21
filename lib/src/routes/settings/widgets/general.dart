import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/routes/entry/entry.dart';
import 'package:recombox/src/rust/method/clear_cache.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/settings/get_settings.dart';
import 'package:recombox/src/rust/method/settings/set_settings.dart';
import 'package:recombox/src/rust/method/watch_state.dart';
import 'package:recombox/src/rust/utils/settings.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';

class General extends StatefulWidget {
  const General({super.key});

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {

  AppColorsScheme appColors = appColorsNotifier.value;
  Settings? settings;

  final List<Map<String, dynamic>> directoryInfo = [];

  static final Map<BigInt, String> cacheSizeMap = {
    BigInt.from(1073741824): '1 GB',
    BigInt.from(5368709120): '5 GB',
    BigInt.from(10737418240): '10 GB',
    BigInt.from(26843545600): '25 GB',
    BigInt.from(53687091200): '50 GB',
  };

  TextEditingController tmdbTextEditingController = TextEditingController(text: "");
  bool isNewTmdbToken = false;

  @override
  void initState() {
    super.initState();
    initStorage();
  }

  Future<void> initStorage() async {
    var result = await getSettings();
    if (result.maxCacheSize == null) {
      result = result.copyWith(maxCacheSize: BigInt.from(5368709120));
    }

    if (context.mounted) {
      setState(() {
        settings = result;
        tmdbTextEditingController.text = settings!.tmdbRatToken ?? "";
        directoryInfo.clear();
        directoryInfo.add({
          "label": "App Data Directory",
          "path": settings!.paths.appSupportDir,
          'onChange': () => onChangeDir(1),
          'onReset': () => onResetDir(1)
        });
        directoryInfo.add({
          "label": "App Cache Directory",
          "path": settings!.paths.appCacheDir,
          'onChange': () => onChangeDir(2),
          'onReset': () => onResetDir(2)
        });
      });
    }
  }
  
  Future<void> onResetDir(int index) async {

    switch (index) {
      case 1:
        settings = settings!.copyWith(
          paths: settings!.paths.copyWith(appSupportDir: (await getApplicationSupportDirectory()).path)
        );
        break;
      case 2:
        settings = settings!.copyWith(
          paths: settings!.paths.copyWith(appCacheDir: (await getApplicationCacheDirectory()).path)
        );
        break;
      default: break;
    }


    await setSettings(settings: settings!);
    await initStorage();
      
  }

  Future<void> onChangeDir(int index) async {
    // -> On android ask for file access intent
    if (Platform.isAndroid){
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        final intent = AndroidIntent(
          action: 'android.settings.MANAGE_ALL_FILES_ACCESS_PERMISSION',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        
        // -> Check again to see if permission granted
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          debugPrint("Not yet grant MANAGE_EXTERNAL_STORAGE access permission");
          return;
        }
        // <-
      }
    }
    // <-

    String? selectedDirectory = await FilePicker.getDirectoryPath();

    if (selectedDirectory != null) {
      debugPrint(selectedDirectory);
      switch (index) {
        case 1:
          settings = settings!.copyWith(
            paths: settings!.paths.copyWith(appSupportDir: selectedDirectory)
          );
          break;
        case 2:
          settings = settings!.copyWith(
            paths: settings!.paths.copyWith(appCacheDir: selectedDirectory)
          );
          break;
        default: break;
      }


      await setSettings(settings: settings!);
      await initStorage();
      
    }
  }


  Future<void> onExportFavorite() async {
    final inputFilePath = await getFavoriteDbPath();
    final inputFile = File(inputFilePath);
    if (await inputFile.exists()){
      final bytes = await inputFile.readAsBytes();
      await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'favorite-backup.sqlite',
        bytes: bytes,
      );
    }else{
      showToastWidget(
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appColors.tertiary,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Text(
            "File does not exist yet",
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
    
  }

  Future<void> onImportFavorite() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
    );

    if (result != null) {
      final dir = Directory(path.join(settings!.paths.appSupportDir, "favorite"));

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String inputFilePath = result.files.single.path!;
      if (path.extension(inputFilePath).toLowerCase() != ".sqlite") {
        showToastWidget(
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: appColors.tertiary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Text(
              "Invalid file format. Please select a .sqlite file.",
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
      final inputFile = File(inputFilePath);

      final outputFile = await getFavoriteDbPath();
      await inputFile.copy(outputFile);
    }
  }

  Future<void> onExportWatchStatus() async {
    final inputFilePath = await getWatchStateDbPath();
    final inputFile = File(inputFilePath);
    if (await inputFile.exists()){
      final bytes = await inputFile.readAsBytes();
      await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'watch_state-backup.sqlite',
        bytes: bytes,
      );
    }else{
      showToastWidget(
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appColors.tertiary,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Text(
            "File does not exist yet",
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
    
  }

  Future<void> onImportWatchStatus() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sqlite'], // restrict to .sqlite files
    );

    if (result != null) {
      final dir = Directory(path.join(settings!.paths.appSupportDir, "state"));

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String inputFilePath = result.files.single.path!;
      if (path.extension(inputFilePath).toLowerCase() != ".sqlite") {
        showToastWidget(
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: appColors.tertiary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Text(
              "Invalid file format. Please select a .sqlite file.",
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


      final inputFile = File(inputFilePath);

      final outputFile = await getWatchStateDbPath();
      await inputFile.copy(outputFile);
    }
  }

  Future<void> onUpdateToken(String token) async {
    var ctx = context;
    Settings newSettings = settings!.copyWith(tmdbRatToken: token);
    await setSettings(settings: newSettings);
    if (token.isNotEmpty && token != settings!.tmdbRatToken && ctx.mounted){
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(
          builder: (_) => const EntryScreen(verifySavedToken: true),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    if (settings == null || directoryInfo.isEmpty) return Container();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      "TMDB Read Access Token",
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight(600)
                      ),
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tmdbTextEditingController,
                            obscureText: true, // hides the input
                            decoration: InputDecoration(
                              
                              hintText: "Enter your token",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: appColors.secondary,
                            ),
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && value != settings!.tmdbRatToken){
                                setState(() {
                                  isNewTmdbToken = true;
                                });
                              }else{
                                setState(() {
                                  isNewTmdbToken = false;
                                });
                              }
                            },
                            onSubmitted: (value) async {
                              await onUpdateToken(value);
                            },
                            
                          ),
                        
                        ),
                        if (!isNewTmdbToken)
                          IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: (){
                              tmdbTextEditingController.text = "";
                            },
                            icon: Icon(Icons.delete_forever_rounded),
                            color: Colors.red,
                          ),
                        if (isNewTmdbToken)
                          IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: () async {
                              await onUpdateToken(tmdbTextEditingController.text);
                            },
                            icon: Icon(Icons.check_rounded),
                            color: Colors.green,
                          )
                        
                      ],
                    )

                    
                  ]
                ),
                
                for (final item in directoryInfo) ...[
                  Text(
                    item["label"],
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight(600)
                    ),
                  ),
                  
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Container(
                          color: appColors.tertiary,
                          padding: EdgeInsets.only(left: 10, right: 10, top: 2.5, bottom: 2.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 10,
                            children: [
                              IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                onPressed: item["onChange"],
                                icon: Icon(Icons.folder_rounded),
                                color: appColors.secondary,
                              ),
                              Expanded(
                                child: InkWell(
                                  mouseCursor: SystemMouseCursors.click,
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: item["path"]));
                                    showToastWidget(
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: appColors.tertiary,
                                          borderRadius: BorderRadius.circular(25)
                                        ),
                                        child: Text(
                                          "Path copied to clipboard",
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
                                  
                                  child: Text(
                                    item["path"],
                                    style: GoogleFonts.nunito(
                                      color: appColors.textPrimary,
                                      fontSize: 14
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              
                              IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                onPressed: item["onReset"],
                                icon: Icon(Icons.refresh_rounded),
                                color: appColors.secondary,
                              ),
                            ],
                          ),
                          
                      
                        ),
                      ),
                      
                    ],
                  )

                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 18,
                  children: [
                    Text(
                      "Max Cache Size:",
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight(600)
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: 
                        DropdownButton<BigInt>(
                          isExpanded: true,
                          value: settings!.maxCacheSize,
                          dropdownColor: appColors.tertiary, // background of the opened menu list
                          style: TextStyle(color: appColors.textPrimary), // selected item text
                          iconEnabledColor: appColors.secondary, // the dropdown arrow icon
                          underline: Container(
                            height: 1,
                            color: appColors.secondary,
                          ),
                          items: cacheSizeMap.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value == null) return;
                            
                            var newSettings = settings!.copyWith(maxCacheSize: value);
                            await setSettings(settings: newSettings);

                            if (context.mounted){
                              setState(() {
                                settings = newSettings;
                              });
                            }
                          },
                        ),
                      
                      ),
                  ],
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    enabledMouseCursor: SystemMouseCursors.click,
                    backgroundColor: Colors.red,
                    fixedSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.5)
                    )
                  ),
                  onPressed: clearCache,
                  child: Text(
                    "Clear Cache",
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 18
                    ),
                  ),
                ),
                

                Text(
                  "Backup Favorite",
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight(600)
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                          backgroundColor: appColors.tertiary,
                          fixedSize: Size(180, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.5)
                          )
                        ),
                        onPressed: onImportFavorite,
                        child: Text(
                          "Import Favorite",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                          backgroundColor: appColors.tertiary,
                          fixedSize: Size(180, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.5)
                          )
                        ),
                        onPressed: onExportFavorite,
                        child: Text(
                          "Export Favorite",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18
                          ),
                        ),
                      ),
                      
                    ],
                  )
                ),
                
                Text(
                  "Backup Watch Status",
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight(600)
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 0),
                  child: Wrap(
                    
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                          backgroundColor: appColors.tertiary,
                          fixedSize: Size(220, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.5)
                          )
                        ),
                        onPressed: onImportWatchStatus,
                        child: Text(
                          "Import Watch Status",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18,
                            
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                          backgroundColor: appColors.tertiary,
                          fixedSize: Size(220, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.5)
                          )
                        ),
                        onPressed: onExportWatchStatus,
                        child: Text(
                          "Export Watch Status",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}