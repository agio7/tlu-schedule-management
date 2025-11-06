// screens/shared/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // control visibility of password
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập, giờ sẽ gọi trực tiếp provider
  Future<void> _handleLogin(AuthProvider auth) async {
    // Chỉ chạy khi form hợp lệ
    if (!_formKey.currentState!.validate()) return;

    // Gọi hàm đăng nhập từ provider
    await auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    // Provider sẽ tự động xử lý việc điều hướng nếu thành công
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe và tự động cập nhật UI khi có thay đổi
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          body: Container(
            // ... (Phần trang trí gradient giữ nguyên)
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                  Color(0xFF90CAF9),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    // ... (Phần Card giữ nguyên)
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ... (Phần Logo và Title giữ nguyên)
                            Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    borderRadius: BorderRadius.circular(40)),
                                child: const Icon(Icons.school,
                                    size: 40, color: Colors.white)),
                            const SizedBox(height: 24),
                            const Text('Hệ thống Quản lý',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2))),
                            const Text('Lịch trình Giảng dạy',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1976D2))),
                            const SizedBox(height: 8),
                            const Text('Trường Đại học Thủy lợi',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 32),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              // 1. THÊM HÀNH ĐỘNG KHI GÕ: Xóa lỗi cũ
                              onChanged: (_) => auth.clearError(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                if (!value.contains('@')) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field with visibility toggle
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              // 1. THÊM HÀNH ĐỘNG KHI GÕ: Xóa lỗi cũ
                              onChanged: (_) => auth.clearError(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 2. HIỂN THỊ LỖI NẾU CÓ
                            if (auth.errorMessage != null)
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                // Nút sẽ bị vô hiệu hóa khi đang tải
                                onPressed: auth.isLoading
                                    ? null
                                    : () => _handleLogin(auth),
                                child: auth.isLoading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text('Đăng nhập',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                child: const Text('Quên mật khẩu?'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}