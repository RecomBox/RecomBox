import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/rust/method/settings/get_settings.dart';
import 'package:recombox/src/rust/method/settings/set_settings.dart';
import 'package:recombox/src/rust/utils/settings.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class Storage extends StatefulWidget {
  const Storage({super.key});

  @override
  State<Storage> createState() => _StorageState();
}

class _StorageState extends State<Storage> {

  AppColorsScheme appColors = appColorsNotifier.value;
  Settings? settings;

  final List<Map<String, dynamic>> directoryInfo = [];

  @override
  void initState() {
    super.initState();
    initStorage();
  }

  Future<void> initStorage() async {
    final result = await getSettings();
    if (context.mounted) {
      setState(() {
        settings = result;
        directoryInfo.clear();
        directoryInfo.add({
          "label": "App Data Directory",
          "path": settings!.paths.appSupportDir,
          'onChange': () => onChangeDir(1)
        });
        directoryInfo.add({
          "label": "App Cache Directory",
          "path": settings!.paths.appCacheDir,
          'onChange': () => onChangeDir(2)
        });
      });
    }
  }
  
  Future<void> onChangeDir(int index) async {
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
    final inputFilePath = path.join(
      settings!.paths.appSupportDir,
      "favorite",
      "favorite.redb",
    );
    final inputFile = File(inputFilePath);
    if (await inputFile.exists()){
      final bytes = await inputFile.readAsBytes();
      await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'favorite-backup.redb',
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
      allowedExtensions: ['redb'],
    );

    if (result != null) {
      final dir = Directory(path.join(settings!.paths.appSupportDir, "favorite"));

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String inputFilePath = result.files.single.path!;
      if (path.extension(inputFilePath).toLowerCase() != ".redb") {
        showToastWidget(
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: appColors.tertiary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Text(
              "Invalid file format. Please select a .redb file.",
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

      final outputFile = path.join(dir.path, "favorite.redb");
      await inputFile.copy(outputFile);
    }
  }

  Future<void> onExportWatchStatus() async {
    final inputFilePath = path.join(
      settings!.paths.appSupportDir,
      "state",
      "watch_state.redb",
    );
    final inputFile = File(inputFilePath);
    if (await inputFile.exists()){
      final bytes = await inputFile.readAsBytes();
      await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'watch_state-backup.redb',
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
      allowedExtensions: ['redb'], // restrict to .redb files
    );

    if (result != null) {
      final dir = Directory(path.join(settings!.paths.appSupportDir, "state"));

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String inputFilePath = result.files.single.path!;
      if (path.extension(inputFilePath).toLowerCase() != ".redb") {
        showToastWidget(
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: appColors.tertiary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Text(
              "Invalid file format. Please select a .redb file.",
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

      final outputFile = path.join(dir.path, "watch_state.redb");
      await inputFile.copy(outputFile);
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
                for (final item in directoryInfo) ...[
                  Text(
                    item["label"],
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight(600)
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: appColors.tertiary,
                    padding: EdgeInsets.only(left: 10, right: 10, top: 2.5, bottom: 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
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
                          onPressed: item["onChange"],
                          icon: Icon(Icons.folder_rounded),
                          color: appColors.secondary,
                        )
                      ],
                    ),
                  )

                ],
              
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
                          fixedSize: Size(250, 50),
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
                          fixedSize: Size(250, 50),
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