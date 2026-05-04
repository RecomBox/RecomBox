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
