import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';


class AuthProvider extends ChangeNotifier {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final Stream<AuthUser?> authStateChanges;

  AuthProvider({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.authStateChanges,
  }) {
    _user = getCurrentUser();
    _subscription = authStateChanges.listen((user) {
      _user = user;
      _errorMessage = null;
      notifyListeners();
    });
  }

  AuthUser? _user;
  String? _errorMessage;
  bool _isLoading = false;
  late final StreamSubscription<AuthUser?> _subscription;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({required String email, required String password}) async {
    return _run(() async {
      _user = await signIn(email: email, password: password);
    });
  }

  Future<bool> register({required String email, required String password}) async {
    return _run(() async {
      final user = await signUp(email: email, password: password);
      _user = user;
    });
  }

  Future<bool> logout() async {
    return _run(() async {
      await signOut();
      _user = null;
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
