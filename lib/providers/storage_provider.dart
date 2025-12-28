import 'dart:math';
import 'package:flutter/material.dart';

class StorageCategory {
  final String id;
  final String name;
  final int bytes;
  final Color color;
  final IconData icon;

  StorageCategory({
    required this.id,
    required this.name,
    required this.bytes,
    required this.color,
    required this.icon,
  });

  double get percentage => bytes / 1024 / 1024 / 1024 * 100; // Percentage of total
}

class StorageProvider extends ChangeNotifier {
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;

  // Storage values (in bytes)
  int _totalSpace = 64 * 1024 * 1024 * 1024; // 64 GB default
  int _usedSpace = 0;
  int _freeSpace = 0;

  // Categories
  List<StorageCategory> _categories = [];

  bool get isAnalyzing => _isAnalyzing;
  bool get hasAnalyzed => _hasAnalyzed;
  int get totalSpace => _totalSpace;
  int get usedSpace => _usedSpace;
  int get freeSpace => _freeSpace;
  List<StorageCategory> get categories => _categories;

  double get usedPercentage => _totalSpace > 0 ? _usedSpace / _totalSpace : 0;

  Future<void> analyzeStorage() async {
    _isAnalyzing = true;
    notifyListeners();

    // Simulate analysis with realistic delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate mock data
    final random = Random();
    _totalSpace = (64 + random.nextInt(64)) * 1024 * 1024 * 1024; // 64-128 GB

    // Generate category sizes
    final appsSize = (8 + random.nextDouble() * 12) * 1024 * 1024 * 1024;
    final cacheSize = (1 + random.nextDouble() * 4) * 1024 * 1024 * 1024;
    final junkSize = (0.5 + random.nextDouble() * 2) * 1024 * 1024 * 1024;
    final mediaSize = (10 + random.nextDouble() * 20) * 1024 * 1024 * 1024;
    final documentsSize = (2 + random.nextDouble() * 5) * 1024 * 1024 * 1024;
    final otherSize = (1 + random.nextDouble() * 3) * 1024 * 1024 * 1024;

    _usedSpace = (appsSize + cacheSize + junkSize + mediaSize + documentsSize + otherSize).toInt();
    _freeSpace = _totalSpace - _usedSpace;

    _categories = [
      StorageCategory(
        id: 'apps',
        name: 'Apps',
        bytes: appsSize.toInt(),
        color: const Color(0xFF5C6BC0),
        icon: Icons.apps,
      ),
      StorageCategory(
        id: 'cache',
        name: 'Cache',
        bytes: cacheSize.toInt(),
        color: const Color(0xFFFF7043),
        icon: Icons.cached,
      ),
      StorageCategory(
        id: 'junk',
        name: 'Junk',
        bytes: junkSize.toInt(),
        color: const Color(0xFFFFCA28),
        icon: Icons.delete_outline,
      ),
      StorageCategory(
        id: 'media',
        name: 'Media',
        bytes: mediaSize.toInt(),
        color: const Color(0xFF26A69A),
        icon: Icons.photo_library,
      ),
      StorageCategory(
        id: 'documents',
        name: 'Documents',
        bytes: documentsSize.toInt(),
        color: const Color(0xFF42A5F5),
        icon: Icons.description,
      ),
      StorageCategory(
        id: 'other',
        name: 'Other',
        bytes: otherSize.toInt(),
        color: const Color(0xFF78909C),
        icon: Icons.folder,
      ),
    ];

    // Sort by size descending
    _categories.sort((a, b) => b.bytes.compareTo(a.bytes));

    _isAnalyzing = false;
    _hasAnalyzed = true;
    notifyListeners();
  }

  void reset() {
    _isAnalyzing = false;
    _hasAnalyzed = false;
    _categories = [];
    _usedSpace = 0;
    _freeSpace = 0;
    notifyListeners();
  }
}
