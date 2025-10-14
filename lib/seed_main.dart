import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const _SeedApp());
}

class _SeedApp extends StatefulWidget {
  const _SeedApp({super.key});

  @override
  State<_SeedApp> createState() => _SeedAppState();
}

class _SeedAppState extends State<_SeedApp> {
  String _status = 'Seeding Firestore data...';

  @override
  void initState() {
    super.initState();
    _runSeeding();
  }

  Future<void> _runSeeding() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Map asset file -> collection name
      final Map<String, String> fileToCollection = const {
        'users.json': 'users',
        'departments.json': 'departments',
        'subjects.json': 'subjects',
        'classrooms.json': 'classrooms',
        'rooms.json': 'rooms',
        'teachingAssignments.json': 'teachingAssignments',
        'schedules.json': 'schedules',
        'attendance.json': 'attendance',
        'leaveRequests.json': 'leaveRequests',
      };

      int totalDocs = 0;
      for (final entry in fileToCollection.entries) {
        final assetPath = 'seed/${entry.key}';
        final content = await rootBundle.loadString(assetPath);
        final List<dynamic> items = jsonDecode(content) as List<dynamic>;

        final batch = firestore.batch();
        for (final raw in items) {
          if (raw is! Map<String, dynamic>) continue;
          final data = _normalizeData(Map<String, dynamic>.from(raw));
          final id = (data.remove('id') ?? '').toString();
          final docRef = firestore.collection(entry.value).doc(
                id.isEmpty ? null : id,
              );
          batch.set(docRef, data, SetOptions(merge: true));
          totalDocs += 1;
        }

        await batch.commit();
      }

      setState(() {
        _status = 'Seeding completed: $totalDocs documents written.';
      });
    } catch (e) {
      setState(() {
        _status = 'Seeding failed: $e';
      });
    }
  }

  // Convert Firestore timestamp-like maps and ensure types are JSON-friendly
  Map<String, dynamic> _normalizeData(Map<String, dynamic> input) {
    Map<String, dynamic> out = {};
    input.forEach((key, value) {
      out[key] = _normalizeValue(value);
    });
    return out;
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      // Timestamp from export-like: { _seconds: x, _nanoseconds: y }
      if (value.containsKey('_seconds') && value.containsKey('_nanoseconds')) {
        try {
          final seconds = value['_seconds'] as int;
          final nanos = value['_nanoseconds'] as int;
          final millis = seconds * 1000 + (nanos / 1e6).round();
          return Timestamp.fromMillisecondsSinceEpoch(millis);
        } catch (_) {
          // fallthrough to recursive map
        }
      }
      return value.map((k, v) => MapEntry(k, _normalizeValue(v)));
    }
    if (value is List) {
      return value.map(_normalizeValue).toList();
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Firestore Seeder')),
        body: Center(child: Text(_status, textAlign: TextAlign.center)),
      ),
    );
  }
}


