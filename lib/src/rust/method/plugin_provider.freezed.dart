// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plugin_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PluginInfo {
  String get hashedManifestRepoId;
  String get manifestRepoName;
  String get pluginId;
  String get pluginName;
  String get pluginRepoUrl;
  String get pluginIconUrl;

  /// Create a copy of PluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginInfoCopyWith<PluginInfo> get copyWith =>
      _$PluginInfoCopyWithImpl<PluginInfo>(this as PluginInfo, _$identity);

  /// Serializes this PluginInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginInfo &&
            (identical(other.hashedManifestRepoId, hashedManifestRepoId) ||
                other.hashedManifestRepoId == hashedManifestRepoId) &&
            (identical(other.manifestRepoName, manifestRepoName) ||
                other.manifestRepoName == manifestRepoName) &&
            (identical(other.pluginId, pluginId) ||
                other.pluginId == pluginId) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName) &&
            (identical(other.pluginRepoUrl, pluginRepoUrl) ||
                other.pluginRepoUrl == pluginRepoUrl) &&
            (identical(other.pluginIconUrl, pluginIconUrl) ||
                other.pluginIconUrl == pluginIconUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hashedManifestRepoId,
      manifestRepoName, pluginId, pluginName, pluginRepoUrl, pluginIconUrl);

  @override
  String toString() {
    return 'PluginInfo(hashedManifestRepoId: $hashedManifestRepoId, manifestRepoName: $manifestRepoName, pluginId: $pluginId, pluginName: $pluginName, pluginRepoUrl: $pluginRepoUrl, pluginIconUrl: $pluginIconUrl)';
  }
}

/// @nodoc
abstract mixin class $PluginInfoCopyWith<$Res> {
  factory $PluginInfoCopyWith(
          PluginInfo value, $Res Function(PluginInfo) _then) =
      _$PluginInfoCopyWithImpl;
  @useResult
  $Res call(
      {String hashedManifestRepoId,
      String manifestRepoName,
      String pluginId,
      String pluginName,
      String pluginRepoUrl,
      String pluginIconUrl});
}

/// @nodoc
class _$PluginInfoCopyWithImpl<$Res> implements $PluginInfoCopyWith<$Res> {
  _$PluginInfoCopyWithImpl(this._self, this._then);

  final PluginInfo _self;
  final $Res Function(PluginInfo) _then;

  /// Create a copy of PluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hashedManifestRepoId = null,
    Object? manifestRepoName = null,
    Object? pluginId = null,
    Object? pluginName = null,
    Object? pluginRepoUrl = null,
    Object? pluginIconUrl = null,
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
      pluginId: null == pluginId
          ? _self.pluginId
          : pluginId // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// Adds pattern-matching-related methods to [PluginInfo].
extension PluginInfoPatterns on PluginInfo {
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
    TResult Function(_PluginInfo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PluginInfo() when $default != null:
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
    TResult Function(_PluginInfo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PluginInfo():
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
    TResult? Function(_PluginInfo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PluginInfo() when $default != null:
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
            String pluginId,
            String pluginName,
            String pluginRepoUrl,
            String pluginIconUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PluginInfo() when $default != null:
        return $default(
            _that.hashedManifestRepoId,
            _that.manifestRepoName,
            _that.pluginId,
            _that.pluginName,
            _that.pluginRepoUrl,
            _that.pluginIconUrl);
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
            String pluginId,
            String pluginName,
            String pluginRepoUrl,
            String pluginIconUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PluginInfo():
        return $default(
            _that.hashedManifestRepoId,
            _that.manifestRepoName,
            _that.pluginId,
            _that.pluginName,
            _that.pluginRepoUrl,
            _that.pluginIconUrl);
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
            String pluginId,
            String pluginName,
            String pluginRepoUrl,
            String pluginIconUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PluginInfo() when $default != null:
        return $default(
            _that.hashedManifestRepoId,
            _that.manifestRepoName,
            _that.pluginId,
            _that.pluginName,
            _that.pluginRepoUrl,
            _that.pluginIconUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PluginInfo implements PluginInfo {
  const _PluginInfo(
      {required this.hashedManifestRepoId,
      required this.manifestRepoName,
      required this.pluginId,
      required this.pluginName,
      required this.pluginRepoUrl,
      required this.pluginIconUrl});
  factory _PluginInfo.fromJson(Map<String, dynamic> json) =>
      _$PluginInfoFromJson(json);

  @override
  final String hashedManifestRepoId;
  @override
  final String manifestRepoName;
  @override
  final String pluginId;
  @override
  final String pluginName;
  @override
  final String pluginRepoUrl;
  @override
  final String pluginIconUrl;

  /// Create a copy of PluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PluginInfoCopyWith<_PluginInfo> get copyWith =>
      __$PluginInfoCopyWithImpl<_PluginInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PluginInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PluginInfo &&
            (identical(other.hashedManifestRepoId, hashedManifestRepoId) ||
                other.hashedManifestRepoId == hashedManifestRepoId) &&
            (identical(other.manifestRepoName, manifestRepoName) ||
                other.manifestRepoName == manifestRepoName) &&
            (identical(other.pluginId, pluginId) ||
                other.pluginId == pluginId) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName) &&
            (identical(other.pluginRepoUrl, pluginRepoUrl) ||
                other.pluginRepoUrl == pluginRepoUrl) &&
            (identical(other.pluginIconUrl, pluginIconUrl) ||
                other.pluginIconUrl == pluginIconUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hashedManifestRepoId,
      manifestRepoName, pluginId, pluginName, pluginRepoUrl, pluginIconUrl);

  @override
  String toString() {
    return 'PluginInfo(hashedManifestRepoId: $hashedManifestRepoId, manifestRepoName: $manifestRepoName, pluginId: $pluginId, pluginName: $pluginName, pluginRepoUrl: $pluginRepoUrl, pluginIconUrl: $pluginIconUrl)';
  }
}

/// @nodoc
abstract mixin class _$PluginInfoCopyWith<$Res>
    implements $PluginInfoCopyWith<$Res> {
  factory _$PluginInfoCopyWith(
          _PluginInfo value, $Res Function(_PluginInfo) _then) =
      __$PluginInfoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String hashedManifestRepoId,
      String manifestRepoName,
      String pluginId,
      String pluginName,
      String pluginRepoUrl,
      String pluginIconUrl});
}

/// @nodoc
class __$PluginInfoCopyWithImpl<$Res> implements _$PluginInfoCopyWith<$Res> {
  __$PluginInfoCopyWithImpl(this._self, this._then);

  final _PluginInfo _self;
  final $Res Function(_PluginInfo) _then;

  /// Create a copy of PluginInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? hashedManifestRepoId = null,
    Object? manifestRepoName = null,
    Object? pluginId = null,
    Object? pluginName = null,
    Object? pluginRepoUrl = null,
    Object? pluginIconUrl = null,
  }) {
    return _then(_PluginInfo(
      hashedManifestRepoId: null == hashedManifestRepoId
          ? _self.hashedManifestRepoId
          : hashedManifestRepoId // ignore: cast_nullable_to_non_nullable
              as String,
      manifestRepoName: null == manifestRepoName
          ? _self.manifestRepoName
          : manifestRepoName // ignore: cast_nullable_to_non_nullable
              as String,
      pluginId: null == pluginId
          ? _self.pluginId
          : pluginId // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

// dart format on
