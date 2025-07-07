// lib/widgets/email_password_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

enum AuthMode { signUp, login }

class EmailPasswordForm extends StatefulWidget {
  const EmailPasswordForm({super.key});

  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  final _passwordController = TextEditingController();
  String _email = '';
  String _password = '';

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final authProvider = context.read<AuthProvider>();
    bool success = false;

    if (_authMode == AuthMode.login) {
      success = await authProvider.signInWithEmail(_email, _password);
    } else {
      success = await authProvider.signUpWithEmail(_email, _password);
    }

    // Nếu thành công thì không cần làm gì, Wrapper sẽ tự chuyển hướng
    // Nếu thất bại, lỗi đã được hiển thị bởi AuthProvider
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _authMode == AuthMode.login ? 'Đăng nhập' : 'Tạo tài khoản',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('email'),
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) return 'Vui lòng nhập email hợp lệ.';
                return null;
              },
              onSaved: (value) => _email = value!,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              key: const ValueKey('password'),
              controller: _passwordController,
              validator: (value) {
                if (value!.isEmpty || value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
                return null;
              },
              onSaved: (value) => _password = value!,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            if (_authMode == AuthMode.signUp)
              TextFormField(
                key: const ValueKey('confirmPassword'),
                enabled: _authMode == AuthMode.signUp,
                decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu'),
                obscureText: true,
                validator: _authMode == AuthMode.signUp
                    ? (value) {
                  if (value != _passwordController.text) return 'Mật khẩu không khớp!';
                  return null;
                }
                    : null,
              ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (ctx, auth, _) => auth.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                child: Text(_authMode == AuthMode.login ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ'),
              ),
            ),
            TextButton(
              onPressed: _switchAuthMode,
              child: Text(
                  '${_authMode == AuthMode.login ? 'CHƯA CÓ TÀI KHOẢN?' : 'ĐÃ CÓ TÀI KHOẢN?'}'),
            ),
            Consumer<AuthProvider>(
                builder: (ctx, auth, _) {
                  if (auth.errorMessage != null && !auth.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                    );
                  }
                  return const SizedBox.shrink();
                }
            )
          ],
        ),
      ),
    );
  }
}