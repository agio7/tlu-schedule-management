import 'package:flutter/material.dart';
// import '../services/simple_auth_test.dart'; // Removed
import '../services/offline_auth_service.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final _emailController = TextEditingController(text: 'admin@tlu.edu.vn');
  final _passwordController = TextEditingController(text: '123456');
  
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth Test'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Authentication Debug',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testOfflineConnection,
                    child: const Text('Test Offline'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testNoTimeoutLogin,
                    child: const Text('Test Login (No Timeout)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testOfflineLogin,
                    child: const Text('Test Offline Login'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSimpleLogin,
                    child: const Text('Test Simple Login'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _clearResult,
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Result:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing connection...\n';
    });

    try {
      // final result = await SimpleAuthTest.testFirebaseConnection();
      setState(() {
        _result += 'Connection Test Result:\nSimpleAuthTest removed\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += 'Connection Test Error: $e\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testNoTimeoutLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing login without timeout...\n';
    });

    try {
      // final result = await SimpleAuthTest.testNoTimeoutLogin(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      // );
      setState(() {
        _result += 'No Timeout Login Result:\nSimpleAuthTest removed\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += 'No Timeout Login Error: $e\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSimpleLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing simple login...\n';
    });

    try {
      // final result = await SimpleAuthTest.testSimpleLogin(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      // );
      setState(() {
        _result += 'Simple Login Result:\nSimpleAuthTest removed\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += 'Simple Login Error: $e\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testOfflineConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing offline connection...\n';
    });

    try {
      final result = await OfflineAuthService.testConnection();
      setState(() {
        _result += 'Offline Connection Test Result:\n${result.toString()}\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += 'Offline Connection Test Error: $e\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testOfflineLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing offline login...\n';
    });

    try {
      final result = await OfflineAuthService.signInWithFallback(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _result += 'Offline Login Result:\n${result.toString()}\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += 'Offline Login Error: $e\n';
        _isLoading = false;
      });
    }
  }

  void _clearResult() {
    setState(() {
      _result = '';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
