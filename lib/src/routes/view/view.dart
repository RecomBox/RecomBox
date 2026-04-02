import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'dart:io';

import 'package:recombox/src/widgets/title_bar.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});


  @override
  State<ViewScreen> createState() => _ViewState();
}

class _ViewState extends State<ViewScreen> {

  AppColorsScheme appColors = appColorsNotifier.value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.55,
              child: Stack(
                children: [
                  Ink.image(
                    image: NetworkImage("https://simkl.in/posters/18/18854411f3a9f50e0b_ca.webp"),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withAlpha(60),
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
                          Container(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "loki",
                              style: GoogleFonts.nunito(
                                fontSize: 38,
                                fontWeight: FontWeight(800),
                                color: appColors.textPrimary,
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SingleChildScrollView(
                              padding: EdgeInsets.only(left: 12),
                              clipBehavior: Clip.hardEdge,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final contextual in ["RATING", "2021", "ACTION", "ADVENTURE"])
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
                


                  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                    TitleBar(),
                ]
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {

                    },
                    label: Text("Watch Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.secondary,
                      foregroundColor: appColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      )
                    ),
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    style: IconButton.styleFrom(
                      backgroundColor: appColors.secondary,
                      foregroundColor: appColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      )
                    ),
                    child: Icon(Icons.bookmark_outline),
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    style: IconButton.styleFrom(
                      backgroundColor: appColors.secondary,
                      foregroundColor: appColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      )
                    ),
                    child: Icon(Icons.video_library),
                  )
                ],
              )
            ),

            // <- Description
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                "laosajdokf;sjdddddddddddddddddddddddosajdokf;sjdddddddddddddddddddddosajdokf;sjdddddddddddddddddddddosajdokf;sjdddddddddddddddddddddosajdokf;sjdddddddddddddddddddddosajdokf;sjdddddddddddddddddddddosajdokf;sjddddddddddddddddddddd",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: appColors.textPrimary,
                  decoration: TextDecoration.none,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]
        )
      )
      

    );
  }
}