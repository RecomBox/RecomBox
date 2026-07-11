// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Paths {
  String get appConfigDir;
  String get appSupportDir;
  String get appCacheDir;
  String get tempDir;

  /// Create a copy of Paths
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PathsCopyWith<Paths> get copyWith =>
      _$PathsCopyWithImpl<Paths>(this as Paths, _$identity);

  /// Serializes this Paths to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Paths &&
            (identical(other.appConfigDir, appConfigDir) ||
                other.appConfigDir == appConfigDir) &&
            (identical(other.appSupportDir, appSupportDir) ||
                other.appSupportDir == appSupportDir) &&
            (identical(other.appCacheDir, appCacheDir) ||
                other.appCacheDir == appCacheDir) &&
            (identical(other.tempDir, tempDir) || other.tempDir == tempDir));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, appConfigDir, appSupportDir, appCacheDir, tempDir);

  @override
  String toString() {
    return 'Paths(appConfigDir: $appConfigDir, appSupportDir: $appSupportDir, appCacheDir: $appCacheDir, tempDir: $tempDir)';
  }
}

/// @nodoc
abstract mixin class $PathsCopyWith<$Res> {
  factory $PathsCopyWith(Paths value, $Res Function(Paths) _then) =
      _$PathsCopyWithImpl;
  @useResult
  $Res call(
      {String appConfigDir,
      String appSupportDir,
      String appCacheDir,
      String tempDir});
}

/// @nodoc
class _$PathsCopyWithImpl<$Res> implements $PathsCopyWith<$Res> {
  _$PathsCopyWithImpl(this._self, this._then);

  final Paths _self;
  final $Res Function(Paths) _then;

  /// Create a copy of Paths
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appConfigDir = null,
    Object? appSupportDir = null,
    Object? appCacheDir = null,
    Object? tempDir = null,
  }) {
    return _then(_self.copyWith(
      appConfigDir: null == appConfigDir
          ? _self.appConfigDir
          : appConfigDir // ignore: cast_nullable_to_non_nullable
              as String,
      appSupportDir: null == appSupportDir
          ? _self.appSupportDir
          : appSupportDir // ignore: cast_nullable_to_non_nullable
              as String,
      appCacheDir: null == appCacheDir
          ? _self.appCacheDir
          : appCacheDir // ignore: cast_nullable_to_non_nullable
              as String,
      tempDir: null == tempDir
          ? _self.tempDir
          : tempDir // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Paths].
extension PathsPatterns on Paths {
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
    TResult Function(_Paths value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Paths() when $default != null:
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
    TResult Function(_Paths value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Paths():
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
    TResult? Function(_Paths value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Paths() when $default != null:
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
    TResult Function(String appConfigDir, String appSupportDir,
            String appCacheDir, String tempDir)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Paths() when $default != null:
        return $default(_that.appConfigDir, _that.appSupportDir,
            _that.appCacheDir, _that.tempDir);
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
    TResult Function(String appConfigDir, String appSupportDir,
            String appCacheDir, String tempDir)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Paths():
        return $default(_that.appConfigDir, _that.appSupportDir,
            _that.appCacheDir, _that.tempDir);
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
    TResult? Function(String appConfigDir, String appSupportDir,
            String appCacheDir, String tempDir)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Paths() when $default != null:
        return $default(_that.appConfigDir, _that.appSupportDir,
            _that.appCacheDir, _that.tempDir);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Paths implements Paths {
  const _Paths(
      {required this.appConfigDir,
      required this.appSupportDir,
      required this.appCacheDir,
      required this.tempDir});
  factory _Paths.fromJson(Map<String, dynamic> json) => _$PathsFromJson(json);

  @override
  final String appConfigDir;
  @override
  final String appSupportDir;
  @override
  final String appCacheDir;
  @override
  final String tempDir;

  /// Create a copy of Paths
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PathsCopyWith<_Paths> get copyWith =>
      __$PathsCopyWithImpl<_Paths>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PathsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Paths &&
            (identical(other.appConfigDir, appConfigDir) ||
                other.appConfigDir == appConfigDir) &&
            (identical(other.appSupportDir, appSupportDir) ||
                other.appSupportDir == appSupportDir) &&
            (identical(other.appCacheDir, appCacheDir) ||
                other.appCacheDir == appCacheDir) &&
            (identical(other.tempDir, tempDir) || other.tempDir == tempDir));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, appConfigDir, appSupportDir, appCacheDir, tempDir);

  @override
  String toString() {
    return 'Paths(appConfigDir: $appConfigDir, appSupportDir: $appSupportDir, appCacheDir: $appCacheDir, tempDir: $tempDir)';
  }
}

/// @nodoc
abstract mixin class _$PathsCopyWith<$Res> implements $PathsCopyWith<$Res> {
  factory _$PathsCopyWith(_Paths value, $Res Function(_Paths) _then) =
      __$PathsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String appConfigDir,
      String appSupportDir,
      String appCacheDir,
      String tempDir});
}

/// @nodoc
class __$PathsCopyWithImpl<$Res> implements _$PathsCopyWith<$Res> {
  __$PathsCopyWithImpl(this._self, this._then);

  final _Paths _self;
  final $Res Function(_Paths) _then;

  /// Create a copy of Paths
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? appConfigDir = null,
    Object? appSupportDir = null,
    Object? appCacheDir = null,
    Object? tempDir = null,
  }) {
    return _then(_Paths(
      appConfigDir: null == appConfigDir
          ? _self.appConfigDir
          : appConfigDir // ignore: cast_nullable_to_non_nullable
              as String,
      appSupportDir: null == appSupportDir
          ? _self.appSupportDir
          : appSupportDir // ignore: cast_nullable_to_non_nullable
              as String,
      appCacheDir: null == appCacheDir
          ? _self.appCacheDir
          : appCacheDir // ignore: cast_nullable_to_non_nullable
              as String,
      tempDir: null == tempDir
          ? _self.tempDir
          : tempDir // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Settings {
  int get port;
  Paths get paths;
  String get version;
  BigInt? get maxCacheSize;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsCopyWith<Settings> get copyWith =>
      _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Settings &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.paths, paths) || other.paths == paths) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.maxCacheSize, maxCacheSize) ||
                other.maxCacheSize == maxCacheSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, port, paths, version, maxCacheSize);

  @override
  String toString() {
    return 'Settings(port: $port, paths: $paths, version: $version, maxCacheSize: $maxCacheSize)';
  }
}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) =
      _$SettingsCopyWithImpl;
  @useResult
  $Res call({int port, Paths paths, String version, BigInt? maxCacheSize});

  $PathsCopyWith<$Res> get paths;
}

/// @nodoc
class _$SettingsCopyWithImpl<$Res> implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? port = null,
    Object? paths = null,
    Object? version = null,
    Object? maxCacheSize = freezed,
  }) {
    return _then(_self.copyWith(
      port: null == port
          ? _self.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      paths: null == paths
          ? _self.paths
          : paths // ignore: cast_nullable_to_non_nullable
              as Paths,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      maxCacheSize: freezed == maxCacheSize
          ? _self.maxCacheSize
          : maxCacheSize // ignore: cast_nullable_to_non_nullable
              as BigInt?,
    ));
  }

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PathsCopyWith<$Res> get paths {
    return $PathsCopyWith<$Res>(_self.paths, (value) {
      return _then(_self.copyWith(paths: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Settings].
extension SettingsPatterns on Settings {
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
    TResult Function(_Settings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
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
    TResult Function(_Settings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings():
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
    TResult? Function(_Settings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
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
            int port, Paths paths, String version, BigInt? maxCacheSize)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
        return $default(
            _that.port, _that.paths, _that.version, _that.maxCacheSize);
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
            int port, Paths paths, String version, BigInt? maxCacheSize)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings():
        return $default(
            _that.port, _that.paths, _that.version, _that.maxCacheSize);
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
            int port, Paths paths, String version, BigInt? maxCacheSize)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
        return $default(
            _that.port, _that.paths, _that.version, _that.maxCacheSize);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Settings implements Settings {
  const _Settings(
      {required this.port,
      required this.paths,
      required this.version,
      this.maxCacheSize});
  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  @override
  final int port;
  @override
  final Paths paths;
  @override
  final String version;
  @override
  final BigInt? maxCacheSize;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsCopyWith<_Settings> get copyWith =>
      __$SettingsCopyWithImpl<_Settings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Settings &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.paths, paths) || other.paths == paths) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.maxCacheSize, maxCacheSize) ||
                other.maxCacheSize == maxCacheSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, port, paths, version, maxCacheSize);

  @override
  String toString() {
    return 'Settings(port: $port, paths: $paths, version: $version, maxCacheSize: $maxCacheSize)';
  }
}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res>
    implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) =
      __$SettingsCopyWithImpl;
  @override
  @useResult
  $Res call({int port, Paths paths, String version, BigInt? maxCacheSize});

  @override
  $PathsCopyWith<$Res> get paths;
}

/// @nodoc
class __$SettingsCopyWithImpl<$Res> implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? port = null,
    Object? paths = null,
    Object? version = null,
    Object? maxCacheSize = freezed,
  }) {
    return _then(_Settings(
      port: null == port
          ? _self.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      paths: null == paths
          ? _self.paths
          : paths // ignore: cast_nullable_to_non_nullable
              as Paths,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      maxCacheSize: freezed == maxCacheSize
          ? _self.maxCacheSize
          : maxCacheSize // ignore: cast_nullable_to_non_nullable
              as BigInt?,
    ));
  }

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PathsCopyWith<$Res> get paths {
    return $PathsCopyWith<$Res>(_self.paths, (value) {
      return _then(_self.copyWith(paths: value));
    });
  }
}

// dart format on
