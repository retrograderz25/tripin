// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Bạn không cần 'google_sign_in' trong provider này nữa khi chỉ dùng cho web.
// Tuy nhiên, giữ lại nó không gây hại và cần thiết nếu bạn build cho mobile.
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // HÀM MỚI: Đăng ký bằng Email và Mật khẩu
  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true; // Đăng ký thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'Mật khẩu quá yếu.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Tài khoản đã tồn tại với email này.';
      } else {
        _errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false; // Đăng ký thất bại
    }
  }

  // HÀM MỚI: Đăng nhập bằng Email và Mật khẩu
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true; // Đăng nhập thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _errorMessage = 'Email hoặc mật khẩu không đúng.';
      } else {
        _errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false; // Đăng nhập thất bại
    }
  }

  // --- HÀM signInWithGoogle ĐƯỢC THAY ĐỔI HOÀN TOÀN ---
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Tạo một instance của GoogleAuthProvider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // (Tùy chọn) Bạn có thể thêm các phạm vi (scopes) nếu cần truy cập
      // vào các dịch vụ khác của Google như Lịch, Drive,...
      // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');

      // 2. Gọi hàm signInWithPopup của FirebaseAuth
      // Hàm này sẽ tự động mở cửa sổ popup đăng nhập của Google
      await _auth.signInWithPopup(googleProvider);

    } on FirebaseAuthException catch (e) {
      // Bắt các lỗi cụ thể từ Firebase Auth
      _errorMessage = "Đăng nhập thất bại: ${e.message}";
    } catch (e) {
      // Bắt các lỗi chung khác
      _errorMessage = "Đã xảy ra lỗi không xác định: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- HÀM signOut THAY ĐỔI NHỎ ---
  Future<void> signOut() async {
    // Vẫn nên gọi signOut của GoogleSignIn để đảm bảo cookie được xóa sạch
    // trên một số trình duyệt.
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}