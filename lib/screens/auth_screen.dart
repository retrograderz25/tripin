// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/email_password_form.dart'; // Sẽ tạo ở bước sau

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Bọc trong SingleChildScrollView để tránh lỗi tràn màn hình
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chào mừng đến với\ntripin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 50),

              // Nút đăng nhập Google
              if (!authProvider.isLoading)
                ElevatedButton.icon(
                  onPressed: () => authProvider.signInWithGoogle(),
                  icon: Image.asset('assets/google-logo.png', height: 24.0),
                  label: const Text('Tiếp tục với Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),

              const SizedBox(height: 32),

              // Nút đăng nhập bằng Email
              if (!authProvider.isLoading)
                TextButton(
                    onPressed: () {
                      // Hiển thị dialog form
                      showDialog(
                        context: context,
                        builder: (ctx) => const AlertDialog(
                          content: EmailPasswordForm(),
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    },
                    child: const Text('Hoặc đăng nhập bằng Email/Mật khẩu')
                ),

              if (authProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}