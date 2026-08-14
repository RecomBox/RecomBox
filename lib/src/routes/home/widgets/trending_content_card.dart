import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';

class TrendingContentCard extends StatefulWidget {
  const TrendingContentCard({
    super.key,
    required this.trendingContentInfo,
  });

  final TrendingContentInfo trendingContentInfo;

  @override
  State<TrendingContentCard> createState() => _TrendingContentCardState();
}

class _TrendingContentCardState extends State<TrendingContentCard> {
  AppColorsScheme appColors = appColorsNotifier.value;

  void onNavigate(){
    Navigator.pushNamed(
      context,
      '/view',
      arguments: ViewScreenArguments(
        source: SourceExtension.fromString(widget.trendingContentInfo.source), 
        id: widget.trendingContentInfo.id
      )
    );
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
                      image: NetworkImage(
                        widget.trendingContentInfo.thumbnailUrl,
                      ),
                      width: 150,
                      height: 225,
                      fit: BoxFit.fill,
                    ),
                    Text(
                      widget.trendingContentInfo.title,
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 2.5,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: appColors.textSecondary,
                              size: 16,
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                widget.trendingContentInfo.year,
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
                        Row(
                          children: [
                            Row(
                              spacing: 2.5,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget.trendingContentInfo.rating,
                                  style: GoogleFonts.nunito(
                                    color: appColors.textSecondary,
                                    fontSize: 10,
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Icon(
                                  Icons.star,
                                  color: appColors.textSecondary,
                                  size: 16,
                                ),
                              ],
                            )
                          ],
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
