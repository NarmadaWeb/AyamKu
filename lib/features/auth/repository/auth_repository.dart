import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  User? get currentUser => _supabase.auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> watchUserData(String uid) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .map((data) => data.isNotEmpty ? UserModel.fromJson(data.first) : null);
  }

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> createUserWithEmailAndPassword(String email, String password, String name, String phone, String address) async {
    try {
      final response = await _supabase.auth.signUp(email: email, password: password, data: {
        'name': name,
        'phoneNumber': phone,
        'address': address,
      });
      if (response.user != null) {
        try {
          await _saveUserData(response.user!.id, email: email, name: name, phoneNumber: phone, address: address, role: 'user');
        } catch (e) {
          // Log error but don't break the registration flow
          // The user is already created in auth.users
          debugPrint('Error saving user data: $e');
        }
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await _supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserData(String uid, {required String email, String? name, String? phoneNumber, String? address, String? role}) async {
    await _supabase.from('users').upsert({
      'uid': uid,
      'email': email,
      'name': name ?? 'Budi Santoso',
      'phoneNumber': phoneNumber ?? '',
      'address': address ?? '',
      'photoUrl': '',
      'role': role ?? 'user',
      'paymentMethods': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _supabase.from('users').update(data).eq('uid', uid);
  }

  Future<String> uploadProfileImage(String uid, File file) async {
    try {
      final extension = p.extension(file.path).toLowerCase();
      String contentType = 'image/jpeg';
      if (extension == '.png') contentType = 'image/png';
      if (extension == '.webp') contentType = 'image/webp';
      if (extension == '.gif') contentType = 'image/gif';

      // Always use a consistent filename to avoid multiple files for one user
      // But we can include a timestamp for cache busting if needed,
      // however the public URL from getPublicUrl stays the same if filename is the same.
      final path = '$uid$extension';

      try {
        await _supabase.storage.from('avatars').upload(
          path,
          file,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );
      } on StorageException catch (e) {
        if (e.message.contains('already exists') || e.statusCode == '409') {
          await _supabase.storage.from('avatars').update(
            path,
            file,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );
        } else {
          rethrow;
        }
      }

      // Get public URL
      final url = _supabase.storage.from('avatars').getPublicUrl(path);
      // Append a timestamp to the URL to force image refresh in the app (cache busting)
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Upload Error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'ayamsegar://reset-password',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
