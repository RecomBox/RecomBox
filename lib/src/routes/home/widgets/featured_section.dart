import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';

class FeaturedSection extends StatefulWidget {
  const FeaturedSection({
    super.key,
    required this.featuredContentInfo,
  });

  final FeaturedContentInfo featuredContentInfo;


  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection> {
  AppColorsScheme get appColors => appColorsNotifier.value;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              debugPrint("Card tapped!");
            },
            mouseCursor: SystemMouseCursors.click,
            child: Stack(
              children: [
                Ink.image(
                  image: NetworkImage(widget.featuredContentInfo.bannerUrl),
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
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            widget.featuredContentInfo.title,
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
                                for (final contextual in widget.featuredContentInfo.contextual)
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
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: appColors.primary.withAlpha(128)),
                          child: Text(
                            widget.featuredContentInfo.shortDescription,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: appColors.textSecondary,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ))
              ],
            )));
  }
}
