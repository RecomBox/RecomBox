// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EpisodeInfo {
  String get source;
  String get title;
  String get thumbnailUrl;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EpisodeInfoCopyWith<EpisodeInfo> get copyWith =>
      _$EpisodeInfoCopyWithImpl<EpisodeInfo>(this as EpisodeInfo, _$identity);

  /// Serializes this EpisodeInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EpisodeInfo &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, source, title, thumbnailUrl);

  @override
  String toString() {
    return 'EpisodeInfo(source: $source, title: $title, thumbnailUrl: $thumbnailUrl)';
  }
}

/// @nodoc
abstract mixin class $EpisodeInfoCopyWith<$Res> {
  factory $EpisodeInfoCopyWith(
          EpisodeInfo value, $Res Function(EpisodeInfo) _then) =
      _$EpisodeInfoCopyWithImpl;
  @useResult
  $Res call({String source, String title, String thumbnailUrl});
}

/// @nodoc
class _$EpisodeInfoCopyWithImpl<$Res> implements $EpisodeInfoCopyWith<$Res> {
  _$EpisodeInfoCopyWithImpl(this._self, this._then);

  final EpisodeInfo _self;
  final $Res Function(EpisodeInfo) _then;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? title = null,
    Object? thumbnailUrl = null,
  }) {
    return _then(_self.copyWith(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [EpisodeInfo].
extension EpisodeInfoPatterns on EpisodeInfo {
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
    TResult Function(_EpisodeInfo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EpisodeInfo() when $default != null:
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
    TResult Function(_EpisodeInfo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EpisodeInfo():
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
    TResult? Function(_EpisodeInfo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EpisodeInfo() when $default != null:
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
    TResult Function(String source, String title, String thumbnailUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EpisodeInfo() when $default != null:
        return $default(_that.source, _that.title, _that.thumbnailUrl);
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
    TResult Function(String source, String title, String thumbnailUrl) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EpisodeInfo():
        return $default(_that.source, _that.title, _that.thumbnailUrl);
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
    TResult? Function(String source, String title, String thumbnailUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EpisodeInfo() when $default != null:
        return $default(_that.source, _that.title, _that.thumbnailUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EpisodeInfo implements EpisodeInfo {
  const _EpisodeInfo(
      {required this.source, required this.title, required this.thumbnailUrl});
  factory _EpisodeInfo.fromJson(Map<String, dynamic> json) =>
      _$EpisodeInfoFromJson(json);

  @override
  final String source;
  @override
  final String title;
  @override
  final String thumbnailUrl;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EpisodeInfoCopyWith<_EpisodeInfo> get copyWith =>
      __$EpisodeInfoCopyWithImpl<_EpisodeInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EpisodeInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EpisodeInfo &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, source, title, thumbnailUrl);

  @override
  String toString() {
    return 'EpisodeInfo(source: $source, title: $title, thumbnailUrl: $thumbnailUrl)';
  }
}

/// @nodoc
abstract mixin class _$EpisodeInfoCopyWith<$Res>
    implements $EpisodeInfoCopyWith<$Res> {
  factory _$EpisodeInfoCopyWith(
          _EpisodeInfo value, $Res Function(_EpisodeInfo) _then) =
      __$EpisodeInfoCopyWithImpl;
  @override
  @useResult
  $Res call({String source, String title, String thumbnailUrl});
}

/// @nodoc
class __$EpisodeInfoCopyWithImpl<$Res> implements _$EpisodeInfoCopyWith<$Res> {
  __$EpisodeInfoCopyWithImpl(this._self, this._then);

  final _EpisodeInfo _self;
  final $Res Function(_EpisodeInfo) _then;

  /// Create a copy of EpisodeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? source = null,
    Object? title = null,
    Object? thumbnailUrl = null,
  }) {
    return _then(_EpisodeInfo(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ViewContentInfo {
  String get source;
  String get externalId;
  String get url;
  String get title;
  String get titleSecondary;
  String get thumbnailUrl;
  String get bannerUrl;
  List<String> get contextual;
  String get description;
  String get trailerUrl;
  PlatformInt64 get countdown;
  List<String> get pictures;
  List<List<EpisodeInfo>> get episodes;

  /// Create a copy of ViewContentInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ViewContentInfoCopyWith<ViewContentInfo> get copyWith =>
      _$ViewContentInfoCopyWithImpl<ViewContentInfo>(
          this as ViewContentInfo, _$identity);

  /// Serializes this ViewContentInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ViewContentInfo &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.externalId, externalId) ||
                other.externalId == externalId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.titleSecondary, titleSecondary) ||
                other.titleSecondary == titleSecondary) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.bannerUrl, bannerUrl) ||
                other.bannerUrl == bannerUrl) &&
            const DeepCollectionEquality()
                .equals(other.contextual, contextual) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.trailerUrl, trailerUrl) ||
                other.trailerUrl == trailerUrl) &&
            (identical(other.countdown, countdown) ||
                other.countdown == countdown) &&
            const DeepCollectionEquality().equals(other.pictures, pictures) &&
            const DeepCollectionEquality().equals(other.episodes, episodes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      source,
      externalId,
      url,
      title,
      titleSecondary,
      thumbnailUrl,
      bannerUrl,
      const DeepCollectionEquality().hash(contextual),
      description,
      trailerUrl,
      countdown,
      const DeepCollectionEquality().hash(pictures),
      const DeepCollectionEquality().hash(episodes));

  @override
  String toString() {
    return 'ViewContentInfo(source: $source, externalId: $externalId, url: $url, title: $title, titleSecondary: $titleSecondary, thumbnailUrl: $thumbnailUrl, bannerUrl: $bannerUrl, contextual: $contextual, description: $description, trailerUrl: $trailerUrl, countdown: $countdown, pictures: $pictures, episodes: $episodes)';
  }
}

/// @nodoc
abstract mixin class $ViewContentInfoCopyWith<$Res> {
  factory $ViewContentInfoCopyWith(
          ViewContentInfo value, $Res Function(ViewContentInfo) _then) =
      _$ViewContentInfoCopyWithImpl;
  @useResult
  $Res call(
      {String source,
      String externalId,
      String url,
      String title,
      String titleSecondary,
      String thumbnailUrl,
      String bannerUrl,
      List<String> contextual,
      String description,
      String trailerUrl,
      PlatformInt64 countdown,
      List<String> pictures,
      List<List<EpisodeInfo>> episodes});
}

/// @nodoc
class _$ViewContentInfoCopyWithImpl<$Res>
    implements $ViewContentInfoCopyWith<$Res> {
  _$ViewContentInfoCopyWithImpl(this._self, this._then);

  final ViewContentInfo _self;
  final $Res Function(ViewContentInfo) _then;

  /// Create a copy of ViewContentInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? externalId = null,
    Object? url = null,
    Object? title = null,
    Object? titleSecondary = null,
    Object? thumbnailUrl = null,
    Object? bannerUrl = null,
    Object? contextual = null,
    Object? description = null,
    Object? trailerUrl = null,
    Object? countdown = null,
    Object? pictures = null,
    Object? episodes = null,
  }) {
    return _then(_self.copyWith(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      externalId: null == externalId
          ? _self.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      titleSecondary: null == titleSecondary
          ? _self.titleSecondary
          : titleSecondary // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bannerUrl: null == bannerUrl
          ? _self.bannerUrl
          : bannerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      contextual: null == contextual
          ? _self.contextual
          : contextual // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      trailerUrl: null == trailerUrl
          ? _self.trailerUrl
          : trailerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      countdown: null == countdown
          ? _self.countdown
          : countdown // ignore: cast_nullable_to_non_nullable
              as PlatformInt64,
      pictures: null == pictures
          ? _self.pictures
          : pictures // ignore: cast_nullable_to_non_nullable
              as List<String>,
      episodes: null == episodes
          ? _self.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<List<EpisodeInfo>>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ViewContentInfo].
extension ViewContentInfoPatterns on ViewContentInfo {
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
    TResult Function(_ViewContentInfo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ViewContentInfo() when $default != null:
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
    TResult Function(_ViewContentInfo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ViewContentInfo():
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
    TResult? Function(_ViewContentInfo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ViewContentInfo() when $default != null:
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
            String source,
            String externalId,
            String url,
            String title,
            String titleSecondary,
            String thumbnailUrl,
            String bannerUrl,
            List<String> contextual,
            String description,
            String trailerUrl,
            PlatformInt64 countdown,
            List<String> pictures,
            List<List<EpisodeInfo>> episodes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ViewContentInfo() when $default != null:
        return $default(
            _that.source,
            _that.externalId,
            _that.url,
            _that.title,
            _that.titleSecondary,
            _that.thumbnailUrl,
            _that.bannerUrl,
            _that.contextual,
            _that.description,
            _that.trailerUrl,
            _that.countdown,
            _that.pictures,
            _that.episodes);
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
            String source,
            String externalId,
            String url,
            String title,
            String titleSecondary,
            String thumbnailUrl,
            String bannerUrl,
            List<String> contextual,
            String description,
            String trailerUrl,
            PlatformInt64 countdown,
            List<String> pictures,
            List<List<EpisodeInfo>> episodes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ViewContentInfo():
        return $default(
            _that.source,
            _that.externalId,
            _that.url,
            _that.title,
            _that.titleSecondary,
            _that.thumbnailUrl,
            _that.bannerUrl,
            _that.contextual,
            _that.description,
            _that.trailerUrl,
            _that.countdown,
            _that.pictures,
            _that.episodes);
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
            String source,
            String externalId,
            String url,
            String title,
            String titleSecondary,
            String thumbnailUrl,
            String bannerUrl,
            List<String> contextual,
            String description,
            String trailerUrl,
            PlatformInt64 countdown,
            List<String> pictures,
            List<List<EpisodeInfo>> episodes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ViewContentInfo() when $default != null:
        return $default(
            _that.source,
            _that.externalId,
            _that.url,
            _that.title,
            _that.titleSecondary,
            _that.thumbnailUrl,
            _that.bannerUrl,
            _that.contextual,
            _that.description,
            _that.trailerUrl,
            _that.countdown,
            _that.pictures,
            _that.episodes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ViewContentInfo implements ViewContentInfo {
  const _ViewContentInfo(
      {required this.source,
      required this.externalId,
      required this.url,
      required this.title,
      required this.titleSecondary,
      required this.thumbnailUrl,
      required this.bannerUrl,
      required final List<String> contextual,
      required this.description,
      required this.trailerUrl,
      required this.countdown,
      required final List<String> pictures,
      required final List<List<EpisodeInfo>> episodes})
      : _contextual = contextual,
        _pictures = pictures,
        _episodes = episodes;
  factory _ViewContentInfo.fromJson(Map<String, dynamic> json) =>
      _$ViewContentInfoFromJson(json);

  @override
  final String source;
  @override
  final String externalId;
  @override
  final String url;
  @override
  final String title;
  @override
  final String titleSecondary;
  @override
  final String thumbnailUrl;
  @override
  final String bannerUrl;
  final List<String> _contextual;
  @override
  List<String> get contextual {
    if (_contextual is EqualUnmodifiableListView) return _contextual;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contextual);
  }

  @override
  final String description;
  @override
  final String trailerUrl;
  @override
  final PlatformInt64 countdown;
  final List<String> _pictures;
  @override
  List<String> get pictures {
    if (_pictures is EqualUnmodifiableListView) return _pictures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pictures);
  }

  final List<List<EpisodeInfo>> _episodes;
  @override
  List<List<EpisodeInfo>> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  /// Create a copy of ViewContentInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ViewContentInfoCopyWith<_ViewContentInfo> get copyWith =>
      __$ViewContentInfoCopyWithImpl<_ViewContentInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ViewContentInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ViewContentInfo &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.externalId, externalId) ||
                other.externalId == externalId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.titleSecondary, titleSecondary) ||
                other.titleSecondary == titleSecondary) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.bannerUrl, bannerUrl) ||
                other.bannerUrl == bannerUrl) &&
            const DeepCollectionEquality()
                .equals(other._contextual, _contextual) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.trailerUrl, trailerUrl) ||
                other.trailerUrl == trailerUrl) &&
            (identical(other.countdown, countdown) ||
                other.countdown == countdown) &&
            const DeepCollectionEquality().equals(other._pictures, _pictures) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      source,
      externalId,
      url,
      title,
      titleSecondary,
      thumbnailUrl,
      bannerUrl,
      const DeepCollectionEquality().hash(_contextual),
      description,
      trailerUrl,
      countdown,
      const DeepCollectionEquality().hash(_pictures),
      const DeepCollectionEquality().hash(_episodes));

  @override
  String toString() {
    return 'ViewContentInfo(source: $source, externalId: $externalId, url: $url, title: $title, titleSecondary: $titleSecondary, thumbnailUrl: $thumbnailUrl, bannerUrl: $bannerUrl, contextual: $contextual, description: $description, trailerUrl: $trailerUrl, countdown: $countdown, pictures: $pictures, episodes: $episodes)';
  }
}

/// @nodoc
abstract mixin class _$ViewContentInfoCopyWith<$Res>
    implements $ViewContentInfoCopyWith<$Res> {
  factory _$ViewContentInfoCopyWith(
          _ViewContentInfo value, $Res Function(_ViewContentInfo) _then) =
      __$ViewContentInfoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String source,
      String externalId,
      String url,
      String title,
      String titleSecondary,
      String thumbnailUrl,
      String bannerUrl,
      List<String> contextual,
      String description,
      String trailerUrl,
      PlatformInt64 countdown,
      List<String> pictures,
      List<List<EpisodeInfo>> episodes});
}

/// @nodoc
class __$ViewContentInfoCopyWithImpl<$Res>
    implements _$ViewContentInfoCopyWith<$Res> {
  __$ViewContentInfoCopyWithImpl(this._self, this._then);

  final _ViewContentInfo _self;
  final $Res Function(_ViewContentInfo) _then;

  /// Create a copy of ViewContentInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? source = null,
    Object? externalId = null,
    Object? url = null,
    Object? title = null,
    Object? titleSecondary = null,
    Object? thumbnailUrl = null,
    Object? bannerUrl = null,
    Object? contextual = null,
    Object? description = null,
    Object? trailerUrl = null,
    Object? countdown = null,
    Object? pictures = null,
    Object? episodes = null,
  }) {
    return _then(_ViewContentInfo(
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      externalId: null == externalId
          ? _self.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      titleSecondary: null == titleSecondary
          ? _self.titleSecondary
          : titleSecondary // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bannerUrl: null == bannerUrl
          ? _self.bannerUrl
          : bannerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      contextual: null == contextual
          ? _self._contextual
          : contextual // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      trailerUrl: null == trailerUrl
          ? _self.trailerUrl
          : trailerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      countdown: null == countdown
          ? _self.countdown
          : countdown // ignore: cast_nullable_to_non_nullable
              as PlatformInt64,
      pictures: null == pictures
          ? _self._pictures
          : pictures // ignore: cast_nullable_to_non_nullable
              as List<String>,
      episodes: null == episodes
          ? _self._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<List<EpisodeInfo>>,
    ));
  }
}

// dart format on
