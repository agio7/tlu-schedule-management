import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/test_firebase.dart';
import 'services/sample_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Schedule Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // Màu xanh dương của TLU
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const MyHomePage(title: 'TLU Schedule Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isConnected = false;
  String _statusMessage = 'Đang kiểm tra kết nối Firebase...';

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    bool connected = await TestFirebase.testConnection();
    setState(() {
      _isConnected = connected;
      _statusMessage = connected 
          ? '✅ Firebase đã kết nối thành công!' 
          : '❌ Không thể kết nối Firebase';
    });
    
    if (connected) {
      await TestFirebase.testWriteData();
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _statusMessage = 'Đang tạo dữ liệu mẫu...';
    });
    
    try {
      await SampleDataService.createSampleData();
      setState(() {
        _statusMessage = '✅ Đã tạo dữ liệu mẫu thành công!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi khi tạo dữ liệu mẫu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              _isConnected ? Icons.check_circle : Icons.error,
              size: 64,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isConnected) ...[
              const Text(
                'Bạn có thể bắt đầu phát triển các chức năng.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _testFirebaseConnection,
                    child: const Text('Test lại kết nối'),
                  ),
                  ElevatedButton(
                    onPressed: _createSampleData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Tạo dữ liệu mẫu'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

