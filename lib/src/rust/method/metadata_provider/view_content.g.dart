// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EpisodeInfo _$EpisodeInfoFromJson(Map<String, dynamic> json) => _EpisodeInfo(
      source: json['source'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );

Map<String, dynamic> _$EpisodeInfoToJson(_EpisodeInfo instance) =>
    <String, dynamic>{
      'source': instance.source,
      'title': instance.title,
      'thumbnailUrl': instance.thumbnailUrl,
    };

_ViewContentInfo _$ViewContentInfoFromJson(Map<String, dynamic> json) =>
    _ViewContentInfo(
      source: json['source'] as String,
      externalId: json['externalId'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      titleSecondary: json['titleSecondary'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      bannerUrl: json['bannerUrl'] as String,
      contextual: (json['contextual'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String,
      trailerUrl: json['trailerUrl'] as String,
      countdown: (json['countdown'] as num).toInt(),
      pictures:
          (json['pictures'] as List<dynamic>).map((e) => e as String).toList(),
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => EpisodeInfo.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      lastWatchSeasonIndex: json['lastWatchSeasonIndex'] == null
          ? null
          : BigInt.parse(json['lastWatchSeasonIndex'] as String),
      lastWatchEpisodeIndex: json['lastWatchEpisodeIndex'] == null
          ? null
          : BigInt.parse(json['lastWatchEpisodeIndex'] as String),
      lastUpdate: json['lastUpdate'] as String?,
    );

Map<String, dynamic> _$ViewContentInfoToJson(_ViewContentInfo instance) =>
    <String, dynamic>{
      'source': instance.source,
      'externalId': instance.externalId,
      'url': instance.url,
      'title': instance.title,
      'titleSecondary': instance.titleSecondary,
      'thumbnailUrl': instance.thumbnailUrl,
      'bannerUrl': instance.bannerUrl,
      'contextual': instance.contextual,
      'description': instance.description,
      'trailerUrl': instance.trailerUrl,
      'countdown': instance.countdown,
      'pictures': instance.pictures,
      'episodes': instance.episodes,
      'lastWatchSeasonIndex': instance.lastWatchSeasonIndex?.toString(),
      'lastWatchEpisodeIndex': instance.lastWatchEpisodeIndex?.toString(),
      'lastUpdate': instance.lastUpdate,
    };
