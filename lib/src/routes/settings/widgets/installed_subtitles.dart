import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/rust/method/subtitle_provider/get_all_installed_subtitles.dart';
import 'package:recombox/src/rust/method/subtitle_provider/remove_subtitles.dart';
import 'package:recombox/src/rust/utils/settings.dart';

class InstalledSubtitles extends StatefulWidget {
  const InstalledSubtitles({super.key});

  @override
  State<InstalledSubtitles> createState() => _InstalledSubtitlesState();
}

class _InstalledSubtitlesState extends State<InstalledSubtitles> {

  AppColorsScheme appColors = appColorsNotifier.value;
  Settings? settings;

  List<GetAllInstalledSubtitlesData> allInstalledSubtitles = [];

  @override
  void initState() {
    super.initState();
    initInstalledSubtitles();
  }

  Future<void> initInstalledSubtitles() async {
    var result = await getAllInstalledSubtitles();

    if (context.mounted){
      setState(() {
        allInstalledSubtitles = result;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!allInstalledSubtitles.isEmpty)
            Container(
              height: MediaQuery.of(context).size.width*0.4,
              padding: EdgeInsets.all(10),
              child: ListView.separated(
                itemCount: allInstalledSubtitles.length,
                itemBuilder: (context,index){
                  return Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(allInstalledSubtitles[index].title,
                            style: GoogleFonts.nunito(
                              color: appColors.textPrimary,
                              fontSize: 18
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          iconSize: 32,
                          color: Colors.red,
                          onPressed: () async {
                            try{
                              var sub = allInstalledSubtitles[index];

                              await removeSubtitles(
                                source: sub.source,
                                id: sub.id, 
                                seasonIndex: sub.seasonIndex, 
                                episodeIndex: sub.episodeIndex, 
                                subtitleId: sub.subtitleId
                              );
                            
                              if (context.mounted){
                                setState(() {
                                  allInstalledSubtitles.removeAt(index);
                                });
                              }
                            }catch(e){
                              debugPrint(e.toString());
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline)
                        )
                      ],
                    ),
                  );
                }, 
                separatorBuilder: (_,__){
                  return const Divider();
                }, 
                
              )
            )
          else
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              child: Text(
                "No subtitles installed",
                style: GoogleFonts.nunito(
                  color: appColors.textPrimary,
                  fontSize: 18
                ),
                textAlign: TextAlign.start,
              ),
            )
        ],
      ),
    );
  }
}