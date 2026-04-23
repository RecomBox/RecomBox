import 'package:flutter/material.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({
    super.key,
    required this.id,
    required this.externalID,
    required this.title,
    required this.titleSecondary,
    required this.season,
    required this.episode,
    required this.episodeInfo,
  });

  final String id;
  final String externalID;
  final String titleSecondary;
  final String title;
  final BigInt season;
  final BigInt episode;
  final EpisodeInfo episodeInfo;

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool failLoadThumbnail = false;

  void onNavigate() {
    debugPrint(widget.season.toString());
    debugPrint(widget.episode.toString());
    SelectPluginScreenArguments args = SelectPluginScreenArguments(
      source: SourceExtension.fromString(widget.episodeInfo.source),
      id: widget.id,
      externalID: widget.externalID,
      title: widget.title,
      titleSecondary: widget.titleSecondary,
      season: widget.season,
      episode: widget.episode

    );

    Navigator.pushNamed(
      context,
      '/select_plugin',
      arguments: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onNavigate,
        mouseCursor: SystemMouseCursors.click,
        child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
              children: [
                Ink.image(
                  width: 150,
                  height: 100,
                  image: failLoadThumbnail
                    ? const AssetImage('assets/episode_thumbnail_placeholder.jpg')
                    : NetworkImage(widget.episodeInfo.thumbnailUrl),
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
                // Container(
                //   alignment: Alignment.center,
                //   padding: EdgeInsets.only(right: 5, left: 5),
                //   child: Icon(
                //     Icons.save_rounded,
                //     color: appColors.secondary,
                //   )
                // )
              ],
            ),
          ),
        )
      );
  }
}