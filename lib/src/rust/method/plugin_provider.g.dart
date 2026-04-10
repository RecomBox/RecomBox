// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PluginInfo _$PluginInfoFromJson(Map<String, dynamic> json) => _PluginInfo(
      hashedManifestRepoId: json['hashedManifestRepoId'] as String,
      manifestRepoName: json['manifestRepoName'] as String,
      pluginId: json['pluginId'] as String,
      pluginName: json['pluginName'] as String,
      pluginRepoUrl: json['pluginRepoUrl'] as String,
      pluginIconUrl: json['pluginIconUrl'] as String,
    );

Map<String, dynamic> _$PluginInfoToJson(_PluginInfo instance) =>
    <String, dynamic>{
      'hashedManifestRepoId': instance.hashedManifestRepoId,
      'manifestRepoName': instance.manifestRepoName,
      'pluginId': instance.pluginId,
      'pluginName': instance.pluginName,
      'pluginRepoUrl': instance.pluginRepoUrl,
      'pluginIconUrl': instance.pluginIconUrl,
    };
