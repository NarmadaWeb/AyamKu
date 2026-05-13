// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider extends $FunctionalProvider<
    ProductRepository,
    ProductRepository,
    ProductRepository> with $Provider<ProductRepository> {
  ProductRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'productRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'42f17d413cfe7f891cbfebf76274529692f985d0';

@ProviderFor(products)
final productsProvider = ProductsProvider._();

final class ProductsProvider extends $FunctionalProvider<
        AsyncValue<List<ProductModel>>,
        List<ProductModel>,
        Stream<List<ProductModel>>>
    with
        $FutureModifier<List<ProductModel>>,
        $StreamProvider<List<ProductModel>> {
  ProductsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'productsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @$internal
  @override
  $StreamProviderElement<List<ProductModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ProductModel>> create(Ref ref) {
    return products(ref);
  }
}

String _$productsHash() => r'e5fd48282f7c78aa5c1f53e700dca14d1eec6f10';
