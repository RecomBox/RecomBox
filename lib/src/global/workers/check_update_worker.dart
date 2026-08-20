
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/main.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/rust/method/check_update.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ota_update/ota_update.dart';

import 'dart:io';

Future<void> onUpdate(
  String downloadUrl,
  void Function(bool state) setIsDownloading,
  void Function(double state) setDownloadProgress
) async{
  try{
    debugPrint(downloadUrl);
    if (Platform.isAndroid){
      setIsDownloading(true);
      OtaUpdate()
        .execute(
          downloadUrl,
        ).listen(
          (OtaEvent event) {
            if (event.status == OtaStatus.DOWNLOADING) {
              setIsDownloading(true);
              setDownloadProgress(double.parse(event.value??"0")/100);
            } else if (event.status == OtaStatus.INSTALLING) {
              setIsDownloading(false);
            } else if (event.status == OtaStatus.CHECKSUM_ERROR) {
              setIsDownloading(false);
            }
          },
        );
    }else{
      launchUrl(
        Uri.parse(downloadUrl),
        mode: LaunchMode.platformDefault,
      )
        .then((value) => debugPrint(value.toString()))
        .catchError((error) => debugPrint(error.toString()));
    }
  }catch(e){
    debugPrint(e.toString());
    launchUrl(
        Uri.parse(downloadUrl),
        mode: LaunchMode.platformDefault,
      )
        .then((value) => debugPrint(value.toString()))
        .catchError((error) => debugPrint(error.toString()));
  }finally{
    setIsDownloading(false);
  }
}

Future<void> checkUpdateWorker() async {
  while (true) {
    final context = navigatorKey.currentContext;
    if (context != null){
      try{
        final checkResult = await CheckUpdate.newInstance();
        
        if (!context.mounted) return;
        if(checkResult != null){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              bool isDownloading = false;
              double downloadProgress = 0;
              AppColorsScheme appColors = appColorsNotifier.value;

              
              return StatefulBuilder( 
                builder: (context, setState) {
                  


                  void setIsDownloading(bool state){
                    if (context.mounted){
                      setState((){
                        isDownloading = state;
                      });
                    }
                  }

                  void setDownloadProgress(double value){
                    if (context.mounted){
                      setState((){
                        downloadProgress = value;
                      });
                    }
                  }

                  return AlertDialog(
                    backgroundColor: appColors.tertiary,
                    title: Column(
                      spacing: 15,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'New update available v${checkResult.latestVersion}',
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight(800),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isDownloading ? 'Updating...' : 'Update Now?',
                            style: GoogleFonts.nunito(
                              color: appColors.textSecondary,
                              fontSize: 24,
                              fontWeight: FontWeight(600),
                            ),
                            textAlign: TextAlign.end,
                          )
                        ),
                      ],
                    ),
                    
                    actions: [
                      if (!isDownloading) ...[
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
                          onPressed: ()=> onUpdate(
                            checkResult.downloadUrl,
                            setIsDownloading,
                            setDownloadProgress
                          ),
                        ),
                      
                      ],
                      if (isDownloading) 
                        SizedBox(
                          height: 5,
                          child: LinearProgressIndicator(
                            value: downloadProgress,
                            color: appColors.accentSecondary,
                          ),
                        )
                    ],
                  );
                
                }
              );
            }
          );
        }

      }catch(e){
        debugPrint(e.toString());
      }
      await Future.delayed(Duration(hours: 1));
    }else{
      await Future.delayed(Duration(seconds: 1));
    }
    
  }
}
