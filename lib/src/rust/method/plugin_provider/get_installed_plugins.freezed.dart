// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_installed_plugins.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstalledPluginInfo {
  String get hashedManifestRepoId;
  String get manifestRepoName;
  String get pluginName;
  String get pluginRepoUrl;
  String get pluginIconUrl;
  String get pluginPath;
  String get pluginVersion;

  /// Create a copy of InstalledPluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstalledPluginInfoCopyWith<InstalledPluginInfo> get copyWith =>
      _$InstalledPluginInfoCopyWithImpl<InstalledPluginInfo>(
          this as InstalledPluginInfo, _$identity);

  /// Serializes this InstalledPluginInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstalledPluginInfo &&
            (identical(other.hashedManifestRepoId, hashedManifestRepoId) ||
                other.hashedManifestRepoId == hashedManifestRepoId) &&
            (identical(other.manifestRepoName, manifestRepoName) ||
                other.manifestRepoName == manifestRepoName) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName) &&
            (identical(other.pluginRepoUrl, pluginRepoUrl) ||
                other.pluginRepoUrl == pluginRepoUrl) &&
            (identical(other.pluginIconUrl, pluginIconUrl) ||
                other.pluginIconUrl == pluginIconUrl) &&
            (identical(other.pluginPath, pluginPath) ||
                other.pluginPath == pluginPath) &&
            (identical(other.pluginVersion, pluginVersion) ||
                other.pluginVersion == pluginVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hashedManifestRepoId,
      manifestRepoName,
      pluginName,
      pluginRepoUrl,
      pluginIconUrl,
      pluginPath,
      pluginVersion);

  @override
  String toString() {
    return 'InstalledPluginInfo(hashedManifestRepoId: $hashedManifestRepoId, manifestRepoName: $manifestRepoName, pluginName: $pluginName, pluginRepoUrl: $pluginRepoUrl, pluginIconUrl: $pluginIconUrl, pluginPath: $pluginPath, pluginVersion: $pluginVersion)';
  }
}

/// @nodoc
abstract mixin class $InstalledPluginInfoCopyWith<$Res> {
  factory $InstalledPluginInfoCopyWith(
          InstalledPluginInfo value, $Res Function(InstalledPluginInfo) _then) =
      _$InstalledPluginInfoCopyWithImpl;
  @useResult
  $Res call(
      {String hashedManifestRepoId,
      String manifestRepoName,
      String pluginName,
      String pluginRepoUrl,
      String pluginIconUrl,
      String pluginPath,
      String pluginVersion});
}

/// @nodoc
class _$InstalledPluginInfoCopyWithImpl<$Res>
    implements $InstalledPluginInfoCopyWith<$Res> {
  _$InstalledPluginInfoCopyWithImpl(this._self, this._then);

  final InstalledPluginInfo _self;
  final $Res Function(InstalledPluginInfo) _then;

  /// Create a copy of InstalledPluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hashedManifestRepoId = null,
    Object? manifestRepoName = null,
    Object? pluginName = null,
    Object? pluginRepoUrl = null,
    Object? pluginIconUrl = null,
    Object? pluginPath = null,
    Object? pluginVersion = null,
  }) {
    return _then(_self.copyWith(
      hashedManifestRepoId: null == hashedManifestRepoId
          ? _self.hashedManifestRepoId
          : hashedManifestRepoId // ignore: cast_nullable_to_non_nullable
              as String,
      manifestRepoName: null == manifestRepoName
          ? _self.manifestRepoName
          : manifestRepoName // ignore: cast_nullable_to_non_nullable
              as String,
      pluginName: null == pluginName
          ? _self.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String,
      pluginRepoUrl: null == pluginRepoUrl
          ? _self.pluginRepoUrl
          : pluginRepoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      pluginIconUrl: null == pluginIconUrl
          ? _self.pluginIconUrl
          : pluginIconUrl // ignore: cast_nullable_to_non_nullable
              as String,
      pluginPath: null == pluginPath
          ? _self.pluginPath
          : pluginPath // ignore: cast_nullable_to_non_nullable
              as String,
      pluginVersion: null == pluginVersion
          ? _self.pluginVersion
          : pluginVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [InstalledPluginInfo].
extension InstalledPluginInfoPatterns on InstalledPluginInfo {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InstalledPluginInfo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstalledPluginInfo() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InstalledPluginInfo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstalledPluginInfo():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InstalledPluginInfo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstalledPluginInfo() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String hashedManifestRepoId,
            String manifestRepoName,
            String pluginName,
            String pluginRepoUrl,
            String pluginIconUrl,
            String pluginPath,
            String pluginVersion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstalledPluginInfo() when $default != null:
        return $default(
            _that.hashedManifestRepoId,
            _that.manifestRepoName,
            _that.pluginName,
            _that.pluginRepoUrl,
            _that.pluginIconUrl,
            _that.pluginPath,
            _that.pluginVersion);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String hashedManifestRepoId,
            String manifestRepoName,
            String pluginName,
            String pluginRepoUrl,
            String pluginIconUrl,
            String pluginPath,
            String pluginVersion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstalledPluginInfo():
        return $default(
            _that.hashedManifestRepoId,
            _that.manifestRepoName,
            _that.pluginName,
            _that.pluginRepoUrl,
            _that.pluginIconUrl,
            _that.pluginPath,
            _that.pluginVersion);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String hashedManifestRepoId,
            String manifestRepoName,
            String pluginName,
            String pluginRepoUrl,
            String pluginIconUrl,
            String pluginPath,
            String pluginVersion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstalledPluginInfo() when $default != null:
        return $default(
            _that.hashedManifestRepoId,
            _that.manifestRepoName,
            _that.pluginName,
            _that.pluginRepoUrl,
            _that.pluginIconUrl,
            _that.pluginPath,
            _that.pluginVersion);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InstalledPluginInfo implements InstalledPluginInfo {
  const _InstalledPluginInfo(
      {required this.hashedManifestRepoId,
      required this.manifestRepoName,
      required this.pluginName,
      required this.pluginRepoUrl,
      required this.pluginIconUrl,
      required this.pluginPath,
      required this.pluginVersion});
  factory _InstalledPluginInfo.fromJson(Map<String, dynamic> json) =>
      _$InstalledPluginInfoFromJson(json);

  @override
  final String hashedManifestRepoId;
  @override
  final String manifestRepoName;
  @override
  final String pluginName;
  @override
  final String pluginRepoUrl;
  @override
  final String pluginIconUrl;
  @override
  final String pluginPath;
  @override
  final String pluginVersion;

  /// Create a copy of InstalledPluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstalledPluginInfoCopyWith<_InstalledPluginInfo> get copyWith =>
      __$InstalledPluginInfoCopyWithImpl<_InstalledPluginInfo>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InstalledPluginInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstalledPluginInfo &&
            (identical(other.hashedManifestRepoId, hashedManifestRepoId) ||
                other.hashedManifestRepoId == hashedManifestRepoId) &&
            (identical(other.manifestRepoName, manifestRepoName) ||
                other.manifestRepoName == manifestRepoName) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName) &&
            (identical(other.pluginRepoUrl, pluginRepoUrl) ||
                other.pluginRepoUrl == pluginRepoUrl) &&
            (identical(other.pluginIconUrl, pluginIconUrl) ||
                other.pluginIconUrl == pluginIconUrl) &&
            (identical(other.pluginPath, pluginPath) ||
                other.pluginPath == pluginPath) &&
            (identical(other.pluginVersion, pluginVersion) ||
                other.pluginVersion == pluginVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hashedManifestRepoId,
      manifestRepoName,
      pluginName,
      pluginRepoUrl,
      pluginIconUrl,
      pluginPath,
      pluginVersion);

  @override
  String toString() {
    return 'InstalledPluginInfo(hashedManifestRepoId: $hashedManifestRepoId, manifestRepoName: $manifestRepoName, pluginName: $pluginName, pluginRepoUrl: $pluginRepoUrl, pluginIconUrl: $pluginIconUrl, pluginPath: $pluginPath, pluginVersion: $pluginVersion)';
  }
}

/// @nodoc
abstract mixin class _$InstalledPluginInfoCopyWith<$Res>
    implements $InstalledPluginInfoCopyWith<$Res> {
  factory _$InstalledPluginInfoCopyWith(_InstalledPluginInfo value,
          $Res Function(_InstalledPluginInfo) _then) =
      __$InstalledPluginInfoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String hashedManifestRepoId,
      String manifestRepoName,
      String pluginName,
      String pluginRepoUrl,
      String pluginIconUrl,
      String pluginPath,
      String pluginVersion});
}

/// @nodoc
class __$InstalledPluginInfoCopyWithImpl<$Res>
    implements _$InstalledPluginInfoCopyWith<$Res> {
  __$InstalledPluginInfoCopyWithImpl(this._self, this._then);

  final _InstalledPluginInfo _self;
  final $Res Function(_InstalledPluginInfo) _then;

  /// Create a copy of InstalledPluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? hashedManifestRepoId = null,
    Object? manifestRepoName = null,
    Object? pluginName = null,
    Object? pluginRepoUrl = null,
    Object? pluginIconUrl = null,
    Object? pluginPath = null,
    Object? pluginVersion = null,
  }) {
    return _then(_InstalledPluginInfo(
      hashedManifestRepoId: null == hashedManifestRepoId
          ? _self.hashedManifestRepoId
          : hashedManifestRepoId // ignore: cast_nullable_to_non_nullable
              as String,
      manifestRepoName: null == manifestRepoName
          ? _self.manifestRepoName
          : manifestRepoName // ignore: cast_nullable_to_non_nullable
              as String,
      pluginName: null == pluginName
          ? _self.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String,
      pluginRepoUrl: null == pluginRepoUrl
          ? _self.pluginRepoUrl
          : pluginRepoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      pluginIconUrl: null == pluginIconUrl
          ? _self.pluginIconUrl
          : pluginIconUrl // ignore: cast_nullable_to_non_nullable
              as String,
      pluginPath: null == pluginPath
          ? _self.pluginPath
          : pluginPath // ignore: cast_nullable_to_non_nullable
              as String,
      pluginVersion: null == pluginVersion
          ? _self.pluginVersion
          : pluginVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
