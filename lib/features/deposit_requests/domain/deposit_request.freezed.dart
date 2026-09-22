// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DepositRequestItem _$DepositRequestItemFromJson(Map<String, dynamic> json) {
  return _DepositRequestItem.fromJson(json);
}

/// @nodoc
mixin _$DepositRequestItem {
  String get productId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  double get requestedQuantity => throw _privateConstructorUsedError;

  /// Serializes this DepositRequestItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DepositRequestItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DepositRequestItemCopyWith<DepositRequestItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepositRequestItemCopyWith<$Res> {
  factory $DepositRequestItemCopyWith(
          DepositRequestItem value, $Res Function(DepositRequestItem) then) =
      _$DepositRequestItemCopyWithImpl<$Res, DepositRequestItem>;
  @useResult
  $Res call({String productId, String sku, double requestedQuantity});
}

/// @nodoc
class _$DepositRequestItemCopyWithImpl<$Res, $Val extends DepositRequestItem>
    implements $DepositRequestItemCopyWith<$Res> {
  _$DepositRequestItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DepositRequestItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? requestedQuantity = null,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      requestedQuantity: null == requestedQuantity
          ? _value.requestedQuantity
          : requestedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DepositRequestItemImplCopyWith<$Res>
    implements $DepositRequestItemCopyWith<$Res> {
  factory _$$DepositRequestItemImplCopyWith(_$DepositRequestItemImpl value,
          $Res Function(_$DepositRequestItemImpl) then) =
      __$$DepositRequestItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String productId, String sku, double requestedQuantity});
}

/// @nodoc
class __$$DepositRequestItemImplCopyWithImpl<$Res>
    extends _$DepositRequestItemCopyWithImpl<$Res, _$DepositRequestItemImpl>
    implements _$$DepositRequestItemImplCopyWith<$Res> {
  __$$DepositRequestItemImplCopyWithImpl(_$DepositRequestItemImpl _value,
      $Res Function(_$DepositRequestItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of DepositRequestItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? requestedQuantity = null,
  }) {
    return _then(_$DepositRequestItemImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      requestedQuantity: null == requestedQuantity
          ? _value.requestedQuantity
          : requestedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DepositRequestItemImpl implements _DepositRequestItem {
  const _$DepositRequestItemImpl(
      {required this.productId,
      required this.sku,
      required this.requestedQuantity});

  factory _$DepositRequestItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DepositRequestItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String sku;
  @override
  final double requestedQuantity;

  @override
  String toString() {
    return 'DepositRequestItem(productId: $productId, sku: $sku, requestedQuantity: $requestedQuantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositRequestItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.requestedQuantity, requestedQuantity) ||
                other.requestedQuantity == requestedQuantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, sku, requestedQuantity);

  /// Create a copy of DepositRequestItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositRequestItemImplCopyWith<_$DepositRequestItemImpl> get copyWith =>
      __$$DepositRequestItemImplCopyWithImpl<_$DepositRequestItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DepositRequestItemImplToJson(
      this,
    );
  }
}

abstract class _DepositRequestItem implements DepositRequestItem {
  const factory _DepositRequestItem(
      {required final String productId,
      required final String sku,
      required final double requestedQuantity}) = _$DepositRequestItemImpl;

  factory _DepositRequestItem.fromJson(Map<String, dynamic> json) =
      _$DepositRequestItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get sku;
  @override
  double get requestedQuantity;

  /// Create a copy of DepositRequestItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepositRequestItemImplCopyWith<_$DepositRequestItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DepositRequest _$DepositRequestFromJson(Map<String, dynamic> json) {
  return _DepositRequest.fromJson(json);
}

/// @nodoc
mixin _$DepositRequest {
  String get requestId => throw _privateConstructorUsedError;
  String get stitchingUserId => throw _privateConstructorUsedError;
  DepositRequestStatus get status => throw _privateConstructorUsedError;
  List<DepositRequestItem> get items => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get submittedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;

  /// Populated only after APPROVED — the FIFO allocation result, for
  /// full traceability of which challans absorbed the return.
  List<String>? get resultingTransactionIds =>
      throw _privateConstructorUsedError;

  /// Serializes this DepositRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DepositRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DepositRequestCopyWith<DepositRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepositRequestCopyWith<$Res> {
  factory $DepositRequestCopyWith(
          DepositRequest value, $Res Function(DepositRequest) then) =
      _$DepositRequestCopyWithImpl<$Res, DepositRequest>;
  @useResult
  $Res call(
      {String requestId,
      String stitchingUserId,
      DepositRequestStatus status,
      List<DepositRequestItem> items,
      String? notes,
      @TimestampConverter() DateTime submittedAt,
      @NullableTimestampConverter() DateTime? reviewedAt,
      String? reviewedBy,
      String? rejectionReason,
      List<String>? resultingTransactionIds});
}

/// @nodoc
class _$DepositRequestCopyWithImpl<$Res, $Val extends DepositRequest>
    implements $DepositRequestCopyWith<$Res> {
  _$DepositRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DepositRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? stitchingUserId = null,
    Object? status = null,
    Object? items = null,
    Object? notes = freezed,
    Object? submittedAt = null,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? rejectionReason = freezed,
    Object? resultingTransactionIds = freezed,
  }) {
    return _then(_value.copyWith(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DepositRequestStatus,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DepositRequestItem>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      resultingTransactionIds: freezed == resultingTransactionIds
          ? _value.resultingTransactionIds
          : resultingTransactionIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DepositRequestImplCopyWith<$Res>
    implements $DepositRequestCopyWith<$Res> {
  factory _$$DepositRequestImplCopyWith(_$DepositRequestImpl value,
          $Res Function(_$DepositRequestImpl) then) =
      __$$DepositRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String requestId,
      String stitchingUserId,
      DepositRequestStatus status,
      List<DepositRequestItem> items,
      String? notes,
      @TimestampConverter() DateTime submittedAt,
      @NullableTimestampConverter() DateTime? reviewedAt,
      String? reviewedBy,
      String? rejectionReason,
      List<String>? resultingTransactionIds});
}

/// @nodoc
class __$$DepositRequestImplCopyWithImpl<$Res>
    extends _$DepositRequestCopyWithImpl<$Res, _$DepositRequestImpl>
    implements _$$DepositRequestImplCopyWith<$Res> {
  __$$DepositRequestImplCopyWithImpl(
      _$DepositRequestImpl _value, $Res Function(_$DepositRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of DepositRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? stitchingUserId = null,
    Object? status = null,
    Object? items = null,
    Object? notes = freezed,
    Object? submittedAt = null,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? rejectionReason = freezed,
    Object? resultingTransactionIds = freezed,
  }) {
    return _then(_$DepositRequestImpl(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DepositRequestStatus,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DepositRequestItem>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      resultingTransactionIds: freezed == resultingTransactionIds
          ? _value._resultingTransactionIds
          : resultingTransactionIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DepositRequestImpl implements _DepositRequest {
  const _$DepositRequestImpl(
      {required this.requestId,
      required this.stitchingUserId,
      required this.status,
      required final List<DepositRequestItem> items,
      this.notes,
      @TimestampConverter() required this.submittedAt,
      @NullableTimestampConverter() this.reviewedAt,
      this.reviewedBy,
      this.rejectionReason,
      final List<String>? resultingTransactionIds})
      : _items = items,
        _resultingTransactionIds = resultingTransactionIds;

  factory _$DepositRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DepositRequestImplFromJson(json);

  @override
  final String requestId;
  @override
  final String stitchingUserId;
  @override
  final DepositRequestStatus status;
  final List<DepositRequestItem> _items;
  @override
  List<DepositRequestItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? notes;
  @override
  @TimestampConverter()
  final DateTime submittedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? reviewedAt;
  @override
  final String? reviewedBy;
  @override
  final String? rejectionReason;

  /// Populated only after APPROVED — the FIFO allocation result, for
  /// full traceability of which challans absorbed the return.
  final List<String>? _resultingTransactionIds;

  /// Populated only after APPROVED — the FIFO allocation result, for
  /// full traceability of which challans absorbed the return.
  @override
  List<String>? get resultingTransactionIds {
    final value = _resultingTransactionIds;
    if (value == null) return null;
    if (_resultingTransactionIds is EqualUnmodifiableListView)
      return _resultingTransactionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DepositRequest(requestId: $requestId, stitchingUserId: $stitchingUserId, status: $status, items: $items, notes: $notes, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, rejectionReason: $rejectionReason, resultingTransactionIds: $resultingTransactionIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositRequestImpl &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.stitchingUserId, stitchingUserId) ||
                other.stitchingUserId == stitchingUserId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            const DeepCollectionEquality().equals(
                other._resultingTransactionIds, _resultingTransactionIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      requestId,
      stitchingUserId,
      status,
      const DeepCollectionEquality().hash(_items),
      notes,
      submittedAt,
      reviewedAt,
      reviewedBy,
      rejectionReason,
      const DeepCollectionEquality().hash(_resultingTransactionIds));

  /// Create a copy of DepositRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositRequestImplCopyWith<_$DepositRequestImpl> get copyWith =>
      __$$DepositRequestImplCopyWithImpl<_$DepositRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DepositRequestImplToJson(
      this,
    );
  }
}

abstract class _DepositRequest implements DepositRequest {
  const factory _DepositRequest(
      {required final String requestId,
      required final String stitchingUserId,
      required final DepositRequestStatus status,
      required final List<DepositRequestItem> items,
      final String? notes,
      @TimestampConverter() required final DateTime submittedAt,
      @NullableTimestampConverter() final DateTime? reviewedAt,
      final String? reviewedBy,
      final String? rejectionReason,
      final List<String>? resultingTransactionIds}) = _$DepositRequestImpl;

  factory _DepositRequest.fromJson(Map<String, dynamic> json) =
      _$DepositRequestImpl.fromJson;

  @override
  String get requestId;
  @override
  String get stitchingUserId;
  @override
  DepositRequestStatus get status;
  @override
  List<DepositRequestItem> get items;
  @override
  String? get notes;
  @override
  @TimestampConverter()
  DateTime get submittedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get reviewedAt;
  @override
  String? get reviewedBy;
  @override
  String? get rejectionReason;

  /// Populated only after APPROVED — the FIFO allocation result, for
  /// full traceability of which challans absorbed the return.
  @override
  List<String>? get resultingTransactionIds;

  /// Create a copy of DepositRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepositRequestImplCopyWith<_$DepositRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
