// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider extends $FunctionalProvider<
    NotificationRepository,
    NotificationRepository,
    NotificationRepository> with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'382d7fc1830266faacdb87fdcf174ee28941afe9';

@ProviderFor(userNotifications)
final userNotificationsProvider = UserNotificationsProvider._();

final class UserNotificationsProvider extends $FunctionalProvider<
        AsyncValue<List<NotificationModel>>,
        List<NotificationModel>,
        Stream<List<NotificationModel>>>
    with
        $FutureModifier<List<NotificationModel>>,
        $StreamProvider<List<NotificationModel>> {
  UserNotificationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userNotificationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userNotificationsHash();

  @$internal
  @override
  $StreamProviderElement<List<NotificationModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<NotificationModel>> create(Ref ref) {
    return userNotifications(ref);
  }
}

String _$userNotificationsHash() => r'c57d742180c267687ffca92eeb9473df337a7f8f';

@ProviderFor(unreadNotificationsCount)
final unreadNotificationsCountProvider = UnreadNotificationsCountProvider._();

final class UnreadNotificationsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  UnreadNotificationsCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unreadNotificationsCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationsCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return unreadNotificationsCount(ref);
  }
}

String _$unreadNotificationsCountHash() =>
    r'345376760bf0424d5145cf4c5a1fdb86b74e41f1';
