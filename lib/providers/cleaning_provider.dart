import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum CleaningState {
  idle,
  scanning,
  scanned,
  cleaning,
  completed,
}

class JunkFile {
  final String name;
  final String path;
  final String category;
  final int size;
  bool isSelected;

  JunkFile({
    required this.name,
    required this.path,
    required this.category,
    required this.size,
    this.isSelected = true,
  });
}

class DuplicateGroup {
  final String hash;
  final List<DuplicateFile> files;
  bool isExpanded;

  DuplicateGroup({
    required this.hash,
    required this.files,
    this.isExpanded = false,
  });

  int get totalSize => files.fold(0, (sum, file) => sum + file.size);
  int get duplicateSize => files.skip(1).fold(0, (sum, file) => sum + file.size);
}

class DuplicateFile {
  final String name;
  final String path;
  final int size;
  final String? thumbnail;
  bool isSelected;
  bool isOriginal;

  DuplicateFile({
    required this.name,
    required this.path,
    required this.size,
    this.thumbnail,
    this.isSelected = false,
    this.isOriginal = false,
  });
}

class CleanHistoryEntry {
  final DateTime timestamp;
  final int freedBytes;
  final String type;

  CleanHistoryEntry({
    required this.timestamp,
    required this.freedBytes,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'freedBytes': freedBytes,
        'type': type,
      };

  factory CleanHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CleanHistoryEntry(
      timestamp: DateTime.parse(json['timestamp']),
      freedBytes: json['freedBytes'],
      type: json['type'],
    );
  }
}

class CleaningProvider extends ChangeNotifier {
  CleaningState _state = CleaningState.idle;
  double _progress = 0.0;
  String _currentTask = '';

  List<JunkFile> _junkFiles = [];
  List<DuplicateGroup> _duplicates = [];

  int _cacheSize = 0;
  int _tempFilesSize = 0;
  int _thumbnailsSize = 0;
  int _logFilesSize = 0;
  int _residualFilesSize = 0;

  int _ramBefore = 0;
  int _ramAfter = 0;

  int _totalFreedSpace = 0;
  int _cleanCount = 0;
  DateTime? _lastCleanDate;
  List<CleanHistoryEntry> _history = [];

  // Getters
  CleaningState get state => _state;
  double get progress => _progress;
  String get currentTask => _currentTask;
  List<JunkFile> get junkFiles => _junkFiles;
  List<DuplicateGroup> get duplicates => _duplicates;
  int get cacheSize => _cacheSize;
  int get tempFilesSize => _tempFilesSize;
  int get thumbnailsSize => _thumbnailsSize;
  int get logFilesSize => _logFilesSize;
  int get residualFilesSize => _residualFilesSize;
  int get ramBefore => _ramBefore;
  int get ramAfter => _ramAfter;
  int get totalFreedSpace => _totalFreedSpace;
  int get cleanCount => _cleanCount;
  DateTime? get lastCleanDate => _lastCleanDate;
  List<CleanHistoryEntry> get history => _history;

  int get totalJunkSize =>
      _cacheSize + _tempFilesSize + _thumbnailsSize + _logFilesSize + _residualFilesSize;

  int get selectedJunkSize =>
      _junkFiles.where((f) => f.isSelected).fold(0, (sum, f) => sum + f.size);

  int get selectedDuplicatesSize => _duplicates.fold(
      0,
      (sum, group) =>
          sum +
          group.files.where((f) => f.isSelected).fold(0, (s, f) => s + f.size));

  CleaningProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final box = Hive.box('history');
    _totalFreedSpace = box.get('totalFreed', defaultValue: 0);
    _cleanCount = box.get('cleanCount', defaultValue: 0);
    final lastClean = box.get('lastClean');
    if (lastClean != null) {
      _lastCleanDate = DateTime.parse(lastClean);
    }
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final box = Hive.box('history');
    await box.put('totalFreed', _totalFreedSpace);
    await box.put('cleanCount', _cleanCount);
    if (_lastCleanDate != null) {
      await box.put('lastClean', _lastCleanDate!.toIso8601String());
    }
  }

  Future<void> startScan() async {
    _state = CleaningState.scanning;
    _progress = 0.0;
    _junkFiles = [];
    notifyListeners();

    final random = Random();
    final scanDuration = 3000 + random.nextInt(5000); // 3-8 seconds
    final steps = 20;
    final stepDuration = scanDuration ~/ steps;

    final tasks = [
      'Scanning cache files...',
      'Analyzing temp files...',
      'Checking thumbnails...',
      'Scanning log files...',
      'Finding residual files...',
      'Detecting app cache...',
      'Processing results...',
    ];

    for (var i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      _progress = (i + 1) / steps;
      _currentTask = tasks[i % tasks.length];
      notifyListeners();
    }

    // Generate mock junk files
    _cacheSize = (50 + random.nextInt(500)) * 1024 * 1024; // 50-550 MB
    _tempFilesSize = (20 + random.nextInt(200)) * 1024 * 1024; // 20-220 MB
    _thumbnailsSize = (30 + random.nextInt(150)) * 1024 * 1024; // 30-180 MB
    _logFilesSize = (5 + random.nextInt(50)) * 1024 * 1024; // 5-55 MB
    _residualFilesSize = (10 + random.nextInt(100)) * 1024 * 1024; // 10-110 MB

    _junkFiles = _generateMockJunkFiles(random);

    _state = CleaningState.scanned;
    _progress = 1.0;
    _currentTask = '';
    notifyListeners();
  }

  List<JunkFile> _generateMockJunkFiles(Random random) {
    final files = <JunkFile>[];

    // Cache files
    final cacheApps = ['Chrome', 'Instagram', 'TikTok', 'YouTube', 'Facebook', 'Twitter'];
    for (final app in cacheApps.take(3 + random.nextInt(3))) {
      files.add(JunkFile(
        name: '$app Cache',
        path: '/data/data/com.${app.toLowerCase()}/cache',
        category: 'cache',
        size: (10 + random.nextInt(100)) * 1024 * 1024,
      ));
    }

    // Temp files
    for (var i = 0; i < 5 + random.nextInt(10); i++) {
      files.add(JunkFile(
        name: 'temp_${random.nextInt(99999)}.tmp',
        path: '/tmp/temp_${random.nextInt(99999)}.tmp',
        category: 'temp',
        size: (1 + random.nextInt(20)) * 1024 * 1024,
      ));
    }

    // Thumbnails
    files.add(JunkFile(
      name: 'Thumbnails',
      path: '/DCIM/.thumbnails',
      category: 'thumbnails',
      size: _thumbnailsSize,
    ));

    // Log files
    files.add(JunkFile(
      name: 'System Logs',
      path: '/var/log',
      category: 'logs',
      size: _logFilesSize,
    ));

    // Residual files
    for (var i = 0; i < 3 + random.nextInt(5); i++) {
      files.add(JunkFile(
        name: 'Residual App ${i + 1}',
        path: '/data/uninstalled_app_$i',
        category: 'residual',
        size: (5 + random.nextInt(30)) * 1024 * 1024,
      ));
    }

    return files;
  }

  Future<void> startCleaning() async {
    _state = CleaningState.cleaning;
    _progress = 0.0;
    notifyListeners();

    final selectedFiles = _junkFiles.where((f) => f.isSelected).toList();
    final totalFiles = selectedFiles.length;

    for (var i = 0; i < totalFiles; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _progress = (i + 1) / totalFiles;
      _currentTask = 'Cleaning ${selectedFiles[i].name}...';
      notifyListeners();
    }

    final freedSpace = selectedJunkSize;
    _totalFreedSpace += freedSpace;
    _cleanCount++;
    _lastCleanDate = DateTime.now();
    await _saveHistory();

    _junkFiles.removeWhere((f) => f.isSelected);
    _cacheSize = 0;
    _tempFilesSize = 0;
    _thumbnailsSize = 0;
    _logFilesSize = 0;
    _residualFilesSize = 0;

    _state = CleaningState.completed;
    _progress = 1.0;
    _currentTask = '';
    notifyListeners();
  }

  Future<void> boostRam() async {
    final random = Random();
    _ramBefore = 2048 + random.nextInt(1024); // 2-3 GB used
    _state = CleaningState.cleaning;
    _progress = 0.0;
    notifyListeners();

    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _progress = (i + 1) / 10;
      notifyListeners();
    }

    _ramAfter = _ramBefore - (200 + random.nextInt(500)); // Free 200-700 MB
    if (_ramAfter < 0) _ramAfter = 0;

    _state = CleaningState.completed;
    notifyListeners();
  }

  Future<void> findDuplicates() async {
    _state = CleaningState.scanning;
    _progress = 0.0;
    _duplicates = [];
    notifyListeners();

    final random = Random();

    // Simulate scanning
    for (var i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _progress = (i + 1) / 15;
      _currentTask = 'Scanning for duplicates... ${(i + 1) * 7}%';
      notifyListeners();
    }

    // Generate mock duplicates
    final numGroups = 2 + random.nextInt(5);
    for (var i = 0; i < numGroups; i++) {
      final numFiles = 2 + random.nextInt(3);
      final size = (1 + random.nextInt(10)) * 1024 * 1024;
      final files = <DuplicateFile>[];

      for (var j = 0; j < numFiles; j++) {
        files.add(DuplicateFile(
          name: 'IMG_${1000 + i}_${j + 1}.jpg',
          path: '/DCIM/Camera/IMG_${1000 + i}_${j + 1}.jpg',
          size: size,
          isOriginal: j == 0,
          isSelected: j != 0,
        ));
      }

      _duplicates.add(DuplicateGroup(
        hash: 'hash_${random.nextInt(999999)}',
        files: files,
      ));
    }

    _state = CleaningState.scanned;
    _progress = 1.0;
    _currentTask = '';
    notifyListeners();
  }

  Future<void> deleteDuplicates() async {
    _state = CleaningState.cleaning;
    _progress = 0.0;
    notifyListeners();

    final toDelete = <DuplicateFile>[];
    for (final group in _duplicates) {
      toDelete.addAll(group.files.where((f) => f.isSelected));
    }

    for (var i = 0; i < toDelete.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _progress = (i + 1) / toDelete.length;
      _currentTask = 'Deleting ${toDelete[i].name}...';
      notifyListeners();
    }

    final freedSpace = selectedDuplicatesSize;
    _totalFreedSpace += freedSpace;
    await _saveHistory();

    for (final group in _duplicates) {
      group.files.removeWhere((f) => f.isSelected);
    }
    _duplicates.removeWhere((g) => g.files.length < 2);

    _state = CleaningState.completed;
    _progress = 1.0;
    _currentTask = '';
    notifyListeners();
  }

  void toggleJunkFile(JunkFile file) {
    file.isSelected = !file.isSelected;
    notifyListeners();
  }

  void selectAllJunk() {
    for (final file in _junkFiles) {
      file.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAllJunk() {
    for (final file in _junkFiles) {
      file.isSelected = false;
    }
    notifyListeners();
  }

  void toggleDuplicateFile(DuplicateFile file) {
    if (!file.isOriginal) {
      file.isSelected = !file.isSelected;
      notifyListeners();
    }
  }

  void toggleDuplicateGroup(DuplicateGroup group) {
    group.isExpanded = !group.isExpanded;
    notifyListeners();
  }

  void reset() {
    _state = CleaningState.idle;
    _progress = 0.0;
    _currentTask = '';
    _junkFiles = [];
    _duplicates = [];
    _cacheSize = 0;
    _tempFilesSize = 0;
    _thumbnailsSize = 0;
    _logFilesSize = 0;
    _residualFilesSize = 0;
    _ramBefore = 0;
    _ramAfter = 0;
    notifyListeners();
  }
}
