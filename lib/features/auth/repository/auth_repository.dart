import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/services.dart';
import '../model/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    GoogleSignIn(),
  );
}

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._auth, this._firestore, this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> watchUserData(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => (doc.exists && doc.data() != null) ? UserModel.fromFirestore(doc) : null)
        .handleError((_) => null);
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        // Ensure indra020204@gmail.com is always a seller
        if (email == 'indra020204@gmail.com') {
          final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
          if (doc.exists && doc.data()?['role'] != 'seller') {
            await updateUserData(credential.user!.uid, {'role': 'seller'});
          } else if (!doc.exists) {
            await _saveUserData(credential.user!, email: email, role: 'seller');
          }
        }
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password, String name, String phone, String address) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final role = email == 'indra020204@gmail.com' ? 'seller' : 'user';
        await _saveUserData(credential.user!, email: email, name: name, phoneNumber: phone, address: address, role: role);
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        final email = userCredential.user!.email ?? '';
        final role = email == 'indra020204@gmail.com' ? 'seller' : 'user';

        if (!doc.exists) {
          await _saveUserData(userCredential.user!, email: email, name: userCredential.user!.displayName, role: role);
        } else if (email == 'indra020204@gmail.com' && doc.data()?['role'] != 'seller') {
          await updateUserData(userCredential.user!.uid, {'role': 'seller'});
        }
      }
      return userCredential;
    } on PlatformException catch (e) {
      if (e.code == '10') {
        throw 'Sign-in failed. Please check your internet connection and make sure your Google account is properly configured on this device.';
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserData(User user, {required String email, String? name, String? phoneNumber, String? address, String? role}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'name': name ?? 'Budi Santoso',
      'phoneNumber': phoneNumber ?? '',
      'address': address ?? '',
      'photoUrl': user.photoURL ?? '',
      'role': role ?? 'user',
      'paymentMethods': [],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<String> uploadProfileImage(String uid, File file) async {
    try {
      // Save locally instead of Firebase Storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_$uid${p.extension(file.path)}';
      final localFile = File(p.join(appDir.path, fileName));
      await file.copy(localFile.path);
      return localFile.path;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
