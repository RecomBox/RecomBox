// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadItemKey {
  String get source;
  String get id;
  BigInt get seasonIndex;
  BigInt get episodeIndex;

  /// Create a copy of DownloadItemKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadItemKeyCopyWith<DownloadItemKey> get copyWith =>
      _$DownloadItemKeyCopyWithImpl<DownloadItemKey>(
          this as DownloadItemKey, _$identity);

  /// Serializes this DownloadItemKey to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadItemKey &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.seasonIndex, seasonIndex) ||
                other.seasonIndex == seasonIndex) &&
            (identical(other.episodeIndex, episodeIndex) ||
                other.episodeIndex == episodeIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, source, id, seasonIndex, episodeIndex);

  @override
  String toString() {
    return 'DownloadItemKey(source: $source, id: $id, seasonIndex: $seasonIndex, episodeIndex: $episodeIndex)';
  }
}

/// @nodoc
abstract mixin class $DownloadItemKeyCopyWith<$Res> {
  factory $DownloadItemKeyCopyWith(
          DownloadItemKey value, $Res Function(DownloadItemKey) _then) =
      _$DownloadItemKeyCopyWithImpl;
  @useResult
  $Res call(
      {String source, String id, BigInt seasonIndex, BigInt episodeIndex});
}

/// @nodoc
class _$DownloadItemKeyCopyWithImpl<$Res>
    implements $DownloadItemKeyCopyWith<$Res> {
  _$DownloadItemKeyCopyWithImpl(this._self, this._then);

  final DownloadItemKey _self;
  final $Res Function(DownloadItemKey) _then;

  /// Create a copy of DownloadItemKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? id = null,
    Object? seasonIndex = null,
    Object? episodeIndex = null,
  }) {
    return _then(_self.copyWith(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      seasonIndex: null == seasonIndex
          ? _self.seasonIndex
          : seasonIndex // ignore: cast_nullable_to_non_nullable
              as BigInt,
      episodeIndex: null == episodeIndex
          ? _self.episodeIndex
          : episodeIndex // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// Adds pattern-matching-related methods to [DownloadItemKey].
extension DownloadItemKeyPatterns on DownloadItemKey {
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
    TResult Function(_DownloadItemKey value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadItemKey() when $default != null:
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
    TResult Function(_DownloadItemKey value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemKey():
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
    TResult? Function(_DownloadItemKey value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemKey() when $default != null:
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
            String source, String id, BigInt seasonIndex, BigInt episodeIndex)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadItemKey() when $default != null:
        return $default(
            _that.source, _that.id, _that.seasonIndex, _that.episodeIndex);
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
            String source, String id, BigInt seasonIndex, BigInt episodeIndex)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemKey():
        return $default(
            _that.source, _that.id, _that.seasonIndex, _that.episodeIndex);
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
            String source, String id, BigInt seasonIndex, BigInt episodeIndex)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemKey() when $default != null:
        return $default(
            _that.source, _that.id, _that.seasonIndex, _that.episodeIndex);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DownloadItemKey implements DownloadItemKey {
  const _DownloadItemKey(
      {required this.source,
      required this.id,
      required this.seasonIndex,
      required this.episodeIndex});
  factory _DownloadItemKey.fromJson(Map<String, dynamic> json) =>
      _$DownloadItemKeyFromJson(json);

  @override
  final String source;
  @override
  final String id;
  @override
  final BigInt seasonIndex;
  @override
  final BigInt episodeIndex;

  /// Create a copy of DownloadItemKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadItemKeyCopyWith<_DownloadItemKey> get copyWith =>
      __$DownloadItemKeyCopyWithImpl<_DownloadItemKey>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DownloadItemKeyToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadItemKey &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.seasonIndex, seasonIndex) ||
                other.seasonIndex == seasonIndex) &&
            (identical(other.episodeIndex, episodeIndex) ||
                other.episodeIndex == episodeIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, source, id, seasonIndex, episodeIndex);

  @override
  String toString() {
    return 'DownloadItemKey(source: $source, id: $id, seasonIndex: $seasonIndex, episodeIndex: $episodeIndex)';
  }
}

/// @nodoc
abstract mixin class _$DownloadItemKeyCopyWith<$Res>
    implements $DownloadItemKeyCopyWith<$Res> {
  factory _$DownloadItemKeyCopyWith(
          _DownloadItemKey value, $Res Function(_DownloadItemKey) _then) =
      __$DownloadItemKeyCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String source, String id, BigInt seasonIndex, BigInt episodeIndex});
}

/// @nodoc
class __$DownloadItemKeyCopyWithImpl<$Res>
    implements _$DownloadItemKeyCopyWith<$Res> {
  __$DownloadItemKeyCopyWithImpl(this._self, this._then);

  final _DownloadItemKey _self;
  final $Res Function(_DownloadItemKey) _then;

  /// Create a copy of DownloadItemKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? source = null,
    Object? id = null,
    Object? seasonIndex = null,
    Object? episodeIndex = null,
  }) {
    return _then(_DownloadItemKey(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      seasonIndex: null == seasonIndex
          ? _self.seasonIndex
          : seasonIndex // ignore: cast_nullable_to_non_nullable
              as BigInt,
      episodeIndex: null == episodeIndex
          ? _self.episodeIndex
          : episodeIndex // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc
mixin _$DownloadItemValue {
  String get torrentSource;
  BigInt get fileId;
  String get filePath;
  String get mimeType;

  /// Create a copy of DownloadItemValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadItemValueCopyWith<DownloadItemValue> get copyWith =>
      _$DownloadItemValueCopyWithImpl<DownloadItemValue>(
          this as DownloadItemValue, _$identity);

  /// Serializes this DownloadItemValue to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadItemValue &&
            (identical(other.torrentSource, torrentSource) ||
                other.torrentSource == torrentSource) &&
            (identical(other.fileId, fileId) || other.fileId == fileId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, torrentSource, fileId, filePath, mimeType);

  @override
  String toString() {
    return 'DownloadItemValue(torrentSource: $torrentSource, fileId: $fileId, filePath: $filePath, mimeType: $mimeType)';
  }
}

/// @nodoc
abstract mixin class $DownloadItemValueCopyWith<$Res> {
  factory $DownloadItemValueCopyWith(
          DownloadItemValue value, $Res Function(DownloadItemValue) _then) =
      _$DownloadItemValueCopyWithImpl;
  @useResult
  $Res call(
      {String torrentSource, BigInt fileId, String filePath, String mimeType});
}

/// @nodoc
class _$DownloadItemValueCopyWithImpl<$Res>
    implements $DownloadItemValueCopyWith<$Res> {
  _$DownloadItemValueCopyWithImpl(this._self, this._then);

  final DownloadItemValue _self;
  final $Res Function(DownloadItemValue) _then;

  /// Create a copy of DownloadItemValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? torrentSource = null,
    Object? fileId = null,
    Object? filePath = null,
    Object? mimeType = null,
  }) {
    return _then(_self.copyWith(
      torrentSource: null == torrentSource
          ? _self.torrentSource
          : torrentSource // ignore: cast_nullable_to_non_nullable
              as String,
      fileId: null == fileId
          ? _self.fileId
          : fileId // ignore: cast_nullable_to_non_nullable
              as BigInt,
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _self.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [DownloadItemValue].
extension DownloadItemValuePatterns on DownloadItemValue {
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
    TResult Function(_DownloadItemValue value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadItemValue() when $default != null:
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
    TResult Function(_DownloadItemValue value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemValue():
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
    TResult? Function(_DownloadItemValue value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemValue() when $default != null:
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
    TResult Function(String torrentSource, BigInt fileId, String filePath,
            String mimeType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadItemValue() when $default != null:
        return $default(
            _that.torrentSource, _that.fileId, _that.filePath, _that.mimeType);
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
    TResult Function(String torrentSource, BigInt fileId, String filePath,
            String mimeType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemValue():
        return $default(
            _that.torrentSource, _that.fileId, _that.filePath, _that.mimeType);
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
    TResult? Function(String torrentSource, BigInt fileId, String filePath,
            String mimeType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadItemValue() when $default != null:
        return $default(
            _that.torrentSource, _that.fileId, _that.filePath, _that.mimeType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DownloadItemValue implements DownloadItemValue {
  const _DownloadItemValue(
      {required this.torrentSource,
      required this.fileId,
      required this.filePath,
      required this.mimeType});
  factory _DownloadItemValue.fromJson(Map<String, dynamic> json) =>
      _$DownloadItemValueFromJson(json);

  @override
  final String torrentSource;
  @override
  final BigInt fileId;
  @override
  final String filePath;
  @override
  final String mimeType;

  /// Create a copy of DownloadItemValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadItemValueCopyWith<_DownloadItemValue> get copyWith =>
      __$DownloadItemValueCopyWithImpl<_DownloadItemValue>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DownloadItemValueToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadItemValue &&
            (identical(other.torrentSource, torrentSource) ||
                other.torrentSource == torrentSource) &&
            (identical(other.fileId, fileId) || other.fileId == fileId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, torrentSource, fileId, filePath, mimeType);

  @override
  String toString() {
    return 'DownloadItemValue(torrentSource: $torrentSource, fileId: $fileId, filePath: $filePath, mimeType: $mimeType)';
  }
}

/// @nodoc
abstract mixin class _$DownloadItemValueCopyWith<$Res>
    implements $DownloadItemValueCopyWith<$Res> {
  factory _$DownloadItemValueCopyWith(
          _DownloadItemValue value, $Res Function(_DownloadItemValue) _then) =
      __$DownloadItemValueCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String torrentSource, BigInt fileId, String filePath, String mimeType});
}

/// @nodoc
class __$DownloadItemValueCopyWithImpl<$Res>
    implements _$DownloadItemValueCopyWith<$Res> {
  __$DownloadItemValueCopyWithImpl(this._self, this._then);

  final _DownloadItemValue _self;
  final $Res Function(_DownloadItemValue) _then;

  /// Create a copy of DownloadItemValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? torrentSource = null,
    Object? fileId = null,
    Object? filePath = null,
    Object? mimeType = null,
  }) {
    return _then(_DownloadItemValue(
      torrentSource: null == torrentSource
          ? _self.torrentSource
          : torrentSource // ignore: cast_nullable_to_non_nullable
              as String,
      fileId: null == fileId
          ? _self.fileId
          : fileId // ignore: cast_nullable_to_non_nullable
              as BigInt,
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _self.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$DownloadStatus {
  BigInt get progressSize;
  BigInt get totalSize;
  bool get paused;
  bool get done;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadStatusCopyWith<DownloadStatus> get copyWith =>
      _$DownloadStatusCopyWithImpl<DownloadStatus>(
          this as DownloadStatus, _$identity);

  /// Serializes this DownloadStatus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadStatus &&
            (identical(other.progressSize, progressSize) ||
                other.progressSize == progressSize) &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize) &&
            (identical(other.paused, paused) || other.paused == paused) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, progressSize, totalSize, paused, done);

  @override
  String toString() {
    return 'DownloadStatus(progressSize: $progressSize, totalSize: $totalSize, paused: $paused, done: $done)';
  }
}

/// @nodoc
abstract mixin class $DownloadStatusCopyWith<$Res> {
  factory $DownloadStatusCopyWith(
          DownloadStatus value, $Res Function(DownloadStatus) _then) =
      _$DownloadStatusCopyWithImpl;
  @useResult
  $Res call({BigInt progressSize, BigInt totalSize, bool paused, bool done});
}

/// @nodoc
class _$DownloadStatusCopyWithImpl<$Res>
    implements $DownloadStatusCopyWith<$Res> {
  _$DownloadStatusCopyWithImpl(this._self, this._then);

  final DownloadStatus _self;
  final $Res Function(DownloadStatus) _then;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progressSize = null,
    Object? totalSize = null,
    Object? paused = null,
    Object? done = null,
  }) {
    return _then(_self.copyWith(
      progressSize: null == progressSize
          ? _self.progressSize
          : progressSize // ignore: cast_nullable_to_non_nullable
              as BigInt,
      totalSize: null == totalSize
          ? _self.totalSize
          : totalSize // ignore: cast_nullable_to_non_nullable
              as BigInt,
      paused: null == paused
          ? _self.paused
          : paused // ignore: cast_nullable_to_non_nullable
              as bool,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [DownloadStatus].
extension DownloadStatusPatterns on DownloadStatus {
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
    TResult Function(_DownloadStatus value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadStatus() when $default != null:
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
    TResult Function(_DownloadStatus value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadStatus():
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
    TResult? Function(_DownloadStatus value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadStatus() when $default != null:
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
            BigInt progressSize, BigInt totalSize, bool paused, bool done)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DownloadStatus() when $default != null:
        return $default(
            _that.progressSize, _that.totalSize, _that.paused, _that.done);
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
            BigInt progressSize, BigInt totalSize, bool paused, bool done)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadStatus():
        return $default(
            _that.progressSize, _that.totalSize, _that.paused, _that.done);
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
            BigInt progressSize, BigInt totalSize, bool paused, bool done)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DownloadStatus() when $default != null:
        return $default(
            _that.progressSize, _that.totalSize, _that.paused, _that.done);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DownloadStatus implements DownloadStatus {
  const _DownloadStatus(
      {required this.progressSize,
      required this.totalSize,
      required this.paused,
      required this.done});
  factory _DownloadStatus.fromJson(Map<String, dynamic> json) =>
      _$DownloadStatusFromJson(json);

  @override
  final BigInt progressSize;
  @override
  final BigInt totalSize;
  @override
  final bool paused;
  @override
  final bool done;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadStatusCopyWith<_DownloadStatus> get copyWith =>
      __$DownloadStatusCopyWithImpl<_DownloadStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DownloadStatusToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadStatus &&
            (identical(other.progressSize, progressSize) ||
                other.progressSize == progressSize) &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize) &&
            (identical(other.paused, paused) || other.paused == paused) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, progressSize, totalSize, paused, done);

  @override
  String toString() {
    return 'DownloadStatus(progressSize: $progressSize, totalSize: $totalSize, paused: $paused, done: $done)';
  }
}

/// @nodoc
abstract mixin class _$DownloadStatusCopyWith<$Res>
    implements $DownloadStatusCopyWith<$Res> {
  factory _$DownloadStatusCopyWith(
          _DownloadStatus value, $Res Function(_DownloadStatus) _then) =
      __$DownloadStatusCopyWithImpl;
  @override
  @useResult
  $Res call({BigInt progressSize, BigInt totalSize, bool paused, bool done});
}

/// @nodoc
class __$DownloadStatusCopyWithImpl<$Res>
    implements _$DownloadStatusCopyWith<$Res> {
  __$DownloadStatusCopyWithImpl(this._self, this._then);

  final _DownloadStatus _self;
  final $Res Function(_DownloadStatus) _then;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? progressSize = null,
    Object? totalSize = null,
    Object? paused = null,
    Object? done = null,
  }) {
    return _then(_DownloadStatus(
      progressSize: null == progressSize
          ? _self.progressSize
          : progressSize // ignore: cast_nullable_to_non_nullable
              as BigInt,
      totalSize: null == totalSize
          ? _self.totalSize
          : totalSize // ignore: cast_nullable_to_non_nullable
              as BigInt,
      paused: null == paused
          ? _self.paused
          : paused // ignore: cast_nullable_to_non_nullable
              as bool,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
