// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuditLogEntry _$AuditLogEntryFromJson(Map<String, dynamic> json) {
  return _AuditLogEntry.fromJson(json);
}

/// @nodoc
mixin _$AuditLogEntry {
  String get logId => throw _privateConstructorUsedError;
  AuditAction get action => throw _privateConstructorUsedError;
  String get actorId => throw _privateConstructorUsedError;
  String get actorRole => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get beforeData => throw _privateConstructorUsedError;
  Map<String, dynamic>? get afterData => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AuditLogEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogEntryCopyWith<AuditLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogEntryCopyWith<$Res> {
  factory $AuditLogEntryCopyWith(
          AuditLogEntry value, $Res Function(AuditLogEntry) then) =
      _$AuditLogEntryCopyWithImpl<$Res, AuditLogEntry>;
  @useResult
  $Res call(
      {String logId,
      AuditAction action,
      String actorId,
      String actorRole,
      String entityType,
      String entityId,
      Map<String, dynamic>? beforeData,
      Map<String, dynamic>? afterData,
      String? reason,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res, $Val extends AuditLogEntry>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? action = null,
    Object? actorId = null,
    Object? actorRole = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? beforeData = freezed,
    Object? afterData = freezed,
    Object? reason = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as AuditAction,
      actorId: null == actorId
          ? _value.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as String,
      actorRole: null == actorRole
          ? _value.actorRole
          : actorRole // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      beforeData: freezed == beforeData
          ? _value.beforeData
          : beforeData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      afterData: freezed == afterData
          ? _value.afterData
          : afterData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditLogEntryImplCopyWith<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  factory _$$AuditLogEntryImplCopyWith(
          _$AuditLogEntryImpl value, $Res Function(_$AuditLogEntryImpl) then) =
      __$$AuditLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String logId,
      AuditAction action,
      String actorId,
      String actorRole,
      String entityType,
      String entityId,
      Map<String, dynamic>? beforeData,
      Map<String, dynamic>? afterData,
      String? reason,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class __$$AuditLogEntryImplCopyWithImpl<$Res>
    extends _$AuditLogEntryCopyWithImpl<$Res, _$AuditLogEntryImpl>
    implements _$$AuditLogEntryImplCopyWith<$Res> {
  __$$AuditLogEntryImplCopyWithImpl(
      _$AuditLogEntryImpl _value, $Res Function(_$AuditLogEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? action = null,
    Object? actorId = null,
    Object? actorRole = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? beforeData = freezed,
    Object? afterData = freezed,
    Object? reason = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AuditLogEntryImpl(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as AuditAction,
      actorId: null == actorId
          ? _value.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as String,
      actorRole: null == actorRole
          ? _value.actorRole
          : actorRole // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      beforeData: freezed == beforeData
          ? _value._beforeData
          : beforeData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      afterData: freezed == afterData
          ? _value._afterData
          : afterData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogEntryImpl implements _AuditLogEntry {
  const _$AuditLogEntryImpl(
      {required this.logId,
      required this.action,
      required this.actorId,
      required this.actorRole,
      required this.entityType,
      required this.entityId,
      final Map<String, dynamic>? beforeData,
      final Map<String, dynamic>? afterData,
      this.reason,
      @TimestampConverter() required this.createdAt})
      : _beforeData = beforeData,
        _afterData = afterData;

  factory _$AuditLogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogEntryImplFromJson(json);

  @override
  final String logId;
  @override
  final AuditAction action;
  @override
  final String actorId;
  @override
  final String actorRole;
  @override
  final String entityType;
  @override
  final String entityId;
  final Map<String, dynamic>? _beforeData;
  @override
  Map<String, dynamic>? get beforeData {
    final value = _beforeData;
    if (value == null) return null;
    if (_beforeData is EqualUnmodifiableMapView) return _beforeData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _afterData;
  @override
  Map<String, dynamic>? get afterData {
    final value = _afterData;
    if (value == null) return null;
    if (_afterData is EqualUnmodifiableMapView) return _afterData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? reason;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'AuditLogEntry(logId: $logId, action: $action, actorId: $actorId, actorRole: $actorRole, entityType: $entityType, entityId: $entityId, beforeData: $beforeData, afterData: $afterData, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogEntryImpl &&
            (identical(other.logId, logId) || other.logId == logId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.actorRole, actorRole) ||
                other.actorRole == actorRole) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality()
                .equals(other._beforeData, _beforeData) &&
            const DeepCollectionEquality()
                .equals(other._afterData, _afterData) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      logId,
      action,
      actorId,
      actorRole,
      entityType,
      entityId,
      const DeepCollectionEquality().hash(_beforeData),
      const DeepCollectionEquality().hash(_afterData),
      reason,
      createdAt);

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogEntryImplCopyWith<_$AuditLogEntryImpl> get copyWith =>
      __$$AuditLogEntryImplCopyWithImpl<_$AuditLogEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogEntryImplToJson(
      this,
    );
  }
}

abstract class _AuditLogEntry implements AuditLogEntry {
  const factory _AuditLogEntry(
          {required final String logId,
          required final AuditAction action,
          required final String actorId,
          required final String actorRole,
          required final String entityType,
          required final String entityId,
          final Map<String, dynamic>? beforeData,
          final Map<String, dynamic>? afterData,
          final String? reason,
          @TimestampConverter() required final DateTime createdAt}) =
      _$AuditLogEntryImpl;

  factory _AuditLogEntry.fromJson(Map<String, dynamic> json) =
      _$AuditLogEntryImpl.fromJson;

  @override
  String get logId;
  @override
  AuditAction get action;
  @override
  String get actorId;
  @override
  String get actorRole;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  Map<String, dynamic>? get beforeData;
  @override
  Map<String, dynamic>? get afterData;
  @override
  String? get reason;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogEntryImplCopyWith<_$AuditLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
