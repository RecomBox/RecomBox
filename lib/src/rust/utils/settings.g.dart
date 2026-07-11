// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Paths _$PathsFromJson(Map<String, dynamic> json) => _Paths(
      appConfigDir: json['appConfigDir'] as String,
      appSupportDir: json['appSupportDir'] as String,
      appCacheDir: json['appCacheDir'] as String,
      tempDir: json['tempDir'] as String,
    );

Map<String, dynamic> _$PathsToJson(_Paths instance) => <String, dynamic>{
      'appConfigDir': instance.appConfigDir,
      'appSupportDir': instance.appSupportDir,
      'appCacheDir': instance.appCacheDir,
      'tempDir': instance.tempDir,
    };

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      port: (json['port'] as num).toInt(),
      paths: Paths.fromJson(json['paths'] as Map<String, dynamic>),
      version: json['version'] as String,
      maxCacheSize: json['maxCacheSize'] == null
          ? null
          : BigInt.parse(json['maxCacheSize'] as String),
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'port': instance.port,
      'paths': instance.paths,
      'version': instance.version,
      'maxCacheSize': instance.maxCacheSize?.toString(),
    };
