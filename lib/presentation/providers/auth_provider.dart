import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import 'user_provider.dart';

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth firebaseAuth;
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final GetUserData getUserData;
  final UserProvider userProvider;

  AuthProvider(
    this.loginUser,
    this.registerUser,
    this.logoutUser,
    this.getUserData,
    this.firebaseAuth,
    this.userProvider,
  );

  bool isLoading = false;
  String? errorMessage;
  User? user;

  bool isCheckingAuth = true;

  Future<void> checkAuthStatus() async {
    final fbUser = firebaseAuth.currentUser;
    if (fbUser == null) {
      user = null;
      userProvider.clear();
      notifyListeners();
      return;
    }

    final result = await getUserData(fbUser.uid);

    result.fold(
      (failure) {
        user = null;
        userProvider.clear();
      },
      (usr) {
        user = usr;
        userProvider.setUser(usr);
      },
    );

    isCheckingAuth = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final result = await loginUser(email, password);
    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (usr) {
        user = usr;
        errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();

    final result = await registerUser(name, email, password);
    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (usr) {
        user = usr;
        errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    final result = await logoutUser();
    isLoading = false;

    result.fold(
      (failure) => errorMessage = failure.message,
      (_) => user = null,
    );

    notifyListeners();
  }
}
