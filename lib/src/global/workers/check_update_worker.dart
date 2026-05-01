
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/main.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/rust/method/check_update.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> checkUpdateWorker() async {
  while (true) {
    final context = navigatorKey.currentContext;
    if (context != null){
      try{
        final checkResult = await CheckUpdate.newInstance();
        
        if (!context.mounted) return;
        if(checkResult != null){
          debugPrint(checkResult.toString());
          AppColorsScheme appColors = appColorsNotifier.value;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
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
                      'Update Now?',
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
                      Uri.parse(checkResult.downloadUrl),
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