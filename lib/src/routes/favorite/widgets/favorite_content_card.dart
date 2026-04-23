import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

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
        fromCache: true
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
        borderRadius: BorderRadius.all(Radius.circular(5)),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              onNavigate();
            },
            mouseCursor: SystemMouseCursors.click,
            child: Container(
                width: 155,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    thumbnailUrl.isNotEmpty
                      ? Ink.image(
                        image: NetworkImage(
                          thumbnailUrl,
                        ),
                        width: 155,
                        height: 225,
                        fit: BoxFit.fill,
                        
                      )
                      : Ink.image(
                        image: AssetImage(
                          "assets/thumbnail_placeholder.png",
                        ),
                        width: 155,
                        height: 225,
                        fit: BoxFit.fill,
                        
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
          );
  }
}
