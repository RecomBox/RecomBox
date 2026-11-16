import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'dart:io';

class RecentWatchCard extends StatefulWidget {
  const RecentWatchCard({
    super.key,
    required this.recentWatchInfo,
    required this.viewContentInfo,
  });

  final RecentWatchInfo recentWatchInfo;
  final ViewContentInfo viewContentInfo;

  @override
  State<RecentWatchCard> createState() => _RecentWatchCardState();
}

class _RecentWatchCardState extends State<RecentWatchCard> {
  AppColorsScheme appColors = appColorsNotifier.value;

  void onNavigate(){
    Navigator.pushNamed(
      context,
      '/view',
      arguments: ViewScreenArguments(
        source: SourceExtension.fromString(widget.recentWatchInfo.source),
        id: widget.recentWatchInfo.id
      )
    );
  }

  // e.g. "S01E02" for TV, "E02" for anime, "Full" for movies.
  String get episodeLabel {
    final source = SourceExtension.fromString(widget.recentWatchInfo.source);
    if (source == Source.movies) return "Full";
    final season = (widget.recentWatchInfo.seasonIndex + BigInt.one).toString().padLeft(2, '0');
    final episode = (widget.recentWatchInfo.episodeIndex + BigInt.one).toString().padLeft(2, '0');
    return source == Source.anime ? "E$episode" : "S${season}E$episode";
  }

  ImageProvider get thumbnail {
    final url = widget.viewContentInfo.thumbnailUrl;
    if (url.isEmpty) return const AssetImage("assets/thumbnail_placeholder.png");
    if (url.startsWith("http")) return NetworkImage(url);
    return FileImage(File(url));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              onNavigate();
            },
            mouseCursor: SystemMouseCursors.click,
            child: Container(
                width: 150,
                height: 280,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Ink.image(
                      image: thumbnail,
                      width: 150,
                      height: 225,
                      fit: BoxFit.fill,
                    ),
                    Text(
                      widget.viewContentInfo.title,
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      spacing: 2.5,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: appColors.textSecondary,
                          size: 16,
                        ),
                        Expanded(
                          child: Text(
                            episodeLabel,
                            style: GoogleFonts.nunito(
                              color: appColors.textSecondary,
                              fontSize: 10,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        )
                      ],
                    ),
                  ],
                )
              )
            )
          );
  }
}
