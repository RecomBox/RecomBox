// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadItemKey _$DownloadItemKeyFromJson(Map<String, dynamic> json) =>
    _DownloadItemKey(
      source: json['source'] as String,
      id: json['id'] as String,
      seasonIndex: BigInt.parse(json['seasonIndex'] as String),
      episodeIndex: BigInt.parse(json['episodeIndex'] as String),
    );

Map<String, dynamic> _$DownloadItemKeyToJson(_DownloadItemKey instance) =>
    <String, dynamic>{
      'source': instance.source,
      'id': instance.id,
      'seasonIndex': instance.seasonIndex.toString(),
      'episodeIndex': instance.episodeIndex.toString(),
    };

_DownloadItemValue _$DownloadItemValueFromJson(Map<String, dynamic> json) =>
    _DownloadItemValue(
      torrentSource: json['torrentSource'] as String,
      fileId: BigInt.parse(json['fileId'] as String),
      filePath: json['filePath'] as String,
      mimeType: json['mimeType'] as String,
    );

Map<String, dynamic> _$DownloadItemValueToJson(_DownloadItemValue instance) =>
    <String, dynamic>{
      'torrentSource': instance.torrentSource,
      'fileId': instance.fileId.toString(),
      'filePath': instance.filePath,
      'mimeType': instance.mimeType,
    };

_DownloadStatus _$DownloadStatusFromJson(Map<String, dynamic> json) =>
    _DownloadStatus(
      progressSize: BigInt.parse(json['progressSize'] as String),
      totalSize: BigInt.parse(json['totalSize'] as String),
      paused: json['paused'] as bool,
      done: json['done'] as bool,
    );

Map<String, dynamic> _$DownloadStatusToJson(_DownloadStatus instance) =>
    <String, dynamic>{
      'progressSize': instance.progressSize.toString(),
      'totalSize': instance.totalSize.toString(),
      'paused': instance.paused,
      'done': instance.done,
    };
