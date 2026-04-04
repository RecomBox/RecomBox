import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({
    super.key,
    required this.episodeInfo,
  });

  final EpisodeInfo episodeInfo;

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool failLoadThumbnail = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){

        },
        mouseCursor: SystemMouseCursors.click,
        child: Container(
            width: double.infinity,
            height: 100,
            child: Row(
              children: [
                Ink.image(
                  width: 150,
                  height: 100,
                  image: NetworkImage(failLoadThumbnail ? 'assets/episode_thumbnail_placeholder.jpg' : widget.episodeInfo.thumbnailUrl),
                  fit: BoxFit.cover,
                  onImageError: (_,__){
                    setState(() {
                      failLoadThumbnail = true;
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.episodeInfo.title,
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 3,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    )
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(right: 5, left: 5),
                  child: Icon(
                    Icons.save_rounded,
                    color: appColors.secondary,
                  )
                )
              ],
            ),
          ),
        )
      );
  }
}