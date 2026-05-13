// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cartRepository)
final cartRepositoryProvider = CartRepositoryProvider._();

final class CartRepositoryProvider
    extends $FunctionalProvider<CartRepository, CartRepository, CartRepository>
    with $Provider<CartRepository> {
  CartRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartRepositoryHash();

  @$internal
  @override
  $ProviderElement<CartRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartRepository create(Ref ref) {
    return cartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartRepository>(value),
    );
  }
}

String _$cartRepositoryHash() => r'286b8fcbc1c22a354903c6ac9c87502572edb02b';

@ProviderFor(cartItems)
final cartItemsProvider = CartItemsProvider._();

final class CartItemsProvider extends $FunctionalProvider<
        AsyncValue<List<CartItemModel>>,
        List<CartItemModel>,
        Stream<List<CartItemModel>>>
    with
        $FutureModifier<List<CartItemModel>>,
        $StreamProvider<List<CartItemModel>> {
  CartItemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartItemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<CartItemModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<CartItemModel>> create(Ref ref) {
    return cartItems(ref);
  }
}

String _$cartItemsHash() => r'93ab33427eaafae719e200fa09a1b7a93d12faae';
