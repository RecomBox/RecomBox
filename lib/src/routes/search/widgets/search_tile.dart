import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/method/metadata_provider/search_content.dart';

class SearchTile extends StatefulWidget {
  const SearchTile({
    super.key,
    required this.searchContentInfo
  });

  final SearchContentInfo searchContentInfo;

  @override
  State<SearchTile> createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {

  
  AppColorsScheme appColors = appColorsNotifier.value;

  void onNavigate(){
    Navigator.pushNamed(
      context,
      '/view',
      arguments: ViewScreenArguments(
        source: SourceExtension.fromString(widget.searchContentInfo.source), 
        id: widget.searchContentInfo.id
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onNavigate,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: EdgeInsets.only(bottom: 15, top: 10, left: 10),
          height: 100,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: appColors.strokePrimary
              )
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(2.5)),
                clipBehavior: Clip.antiAlias,
                child: Ink.image(
                  image: NetworkImage(widget.searchContentInfo.thumbnailUrl),
                  width: 50,
                  height: 75,
                  fit: BoxFit.fill,
                  
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.searchContentInfo.title,
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 18,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.left,
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
                              Text(
                                widget.searchContentInfo.year,
                                style: GoogleFonts.nunito(
                                  color: appColors.textSecondary,
                                  fontSize: 10,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                    "#${widget.searchContentInfo.rank??"-".toString()}",
                                    style: GoogleFonts.nunito(
                                      color: appColors.textSecondary,
                                      fontSize: 10,
                                      decoration: TextDecoration.none,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Icon(
                                    Icons.emoji_events,
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
            ],
          )
        )
      )
    );
  }
}