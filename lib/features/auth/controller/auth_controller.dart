import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repository/auth_repository.dart';
import '../model/user_model.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    return ref.watch(authRepositoryProvider).authStateChanges;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password).then((_) => ref.read(authRepositoryProvider).currentUser));
  }

  Future<void> createUserWithEmailAndPassword(String email, String password, String name, String phone, String address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).createUserWithEmailAndPassword(email, password, name, phone, address).then((_) => ref.read(authRepositoryProvider).currentUser));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).signInWithGoogle().then((_) => ref.read(authRepositoryProvider).currentUser));
  }

  Future<void> resetPassword(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authRepositoryProvider).signOut().then((_) => null));
  }
}

@riverpod
Future<UserModel?> currentUserData(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return Future.value(null);
  return ref.watch(authRepositoryProvider).getUserData(user.uid);
}
