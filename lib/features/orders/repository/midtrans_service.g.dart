// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midtrans_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(midtransService)
final midtransServiceProvider = MidtransServiceProvider._();

final class MidtransServiceProvider extends $FunctionalProvider<MidtransService,
    MidtransService, MidtransService> with $Provider<MidtransService> {
  MidtransServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'midtransServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$midtransServiceHash();

  @$internal
  @override
  $ProviderElement<MidtransService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MidtransService create(Ref ref) {
    return midtransService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MidtransService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MidtransService>(value),
    );
  }
}

String _$midtransServiceHash() => r'e1172e7999e25d91347372b5c34b5612d991c150';
