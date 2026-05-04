// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
