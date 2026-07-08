import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';
import 'dart:io';

class FavoriteContentCard extends StatefulWidget {
  const FavoriteContentCard({
    super.key,
    required this.addTitle,
    required this.source,
    required this.id,
  });

  final Function(String title) addTitle;
  final Source source;
  final String id;


  @override
  State<FavoriteContentCard> createState() => _FavoriteContentCardState();
}

class _FavoriteContentCardState extends State<FavoriteContentCard> {
  AppColorsScheme appColors = appColorsNotifier.value;

  String title = "...";
  String thumbnailUrl = "";

  @override
  void initState() {
    super.initState();

    initFavoriteContentCard();
  }

  Future<void> initFavoriteContentCard() async {
    try{
      ViewContentInfo viewContentInfoResult = await ViewContentInfo.get_(
        source: widget.source.name,
        id: widget.id, 
        fromCache: true,
        checkExpire: false
      );

      widget.addTitle(viewContentInfoResult.title);
      if (context.mounted) {
        setState(() {
          title = viewContentInfoResult.title;
          thumbnailUrl = viewContentInfoResult.thumbnailUrl;
        });
      }
    }catch(e){
      debugPrint(e.toString());
      if (context.mounted) {
        setState(() {
          title = "?";
          thumbnailUrl = "";
        });
      }
      
    }
    

  }

  void onNavigate(){
    Navigator.pushNamed(
      context,
      '/view',
      arguments: ViewScreenArguments(
        source: widget.source, 
        id: widget.id
      )
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 155,
            height: 280,
            child: InkWell(
              onTap: () {
                onNavigate();
              },
              mouseCursor: SystemMouseCursors.click,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.transparent,
                    child: Ink.image(
                      image: thumbnailUrl.startsWith('http')
                              ? NetworkImage(thumbnailUrl)
                              : FileImage(File(thumbnailUrl)),
                      width: 155,
                      height: 225,
                      fit: BoxFit.fill,
                    ),
                  ),
                  

                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                ],
              
                )
              )
            )
          )
      );
        
  }
}
