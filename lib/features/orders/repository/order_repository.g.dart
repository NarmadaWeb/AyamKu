// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderRepository)
final orderRepositoryProvider = OrderRepositoryProvider._();

final class OrderRepositoryProvider extends $FunctionalProvider<OrderRepository,
    OrderRepository, OrderRepository> with $Provider<OrderRepository> {
  OrderRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orderRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderRepository create(Ref ref) {
    return orderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRepository>(value),
    );
  }
}

String _$orderRepositoryHash() => r'4dd0247747caf42b3d0c30833256eeb45e90d276';

@ProviderFor(userOrders)
final userOrdersProvider = UserOrdersProvider._();

final class UserOrdersProvider extends $FunctionalProvider<
        AsyncValue<List<OrderModel>>,
        List<OrderModel>,
        Stream<List<OrderModel>>>
    with $FutureModifier<List<OrderModel>>, $StreamProvider<List<OrderModel>> {
  UserOrdersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userOrdersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userOrdersHash();

  @$internal
  @override
  $StreamProviderElement<List<OrderModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<OrderModel>> create(Ref ref) {
    return userOrders(ref);
  }
}

String _$userOrdersHash() => r'ebfe5d094d0db7cd0ff9170d0f5c263c9bc2a356';

@ProviderFor(allOrders)
final allOrdersProvider = AllOrdersProvider._();

final class AllOrdersProvider extends $FunctionalProvider<
        AsyncValue<List<OrderModel>>,
        List<OrderModel>,
        Stream<List<OrderModel>>>
    with $FutureModifier<List<OrderModel>>, $StreamProvider<List<OrderModel>> {
  AllOrdersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allOrdersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allOrdersHash();

  @$internal
  @override
  $StreamProviderElement<List<OrderModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<OrderModel>> create(Ref ref) {
    return allOrders(ref);
  }
}

String _$allOrdersHash() => r'3cdf8abf2fe5c5ea66c7108e69b6d2a5cee656da';
