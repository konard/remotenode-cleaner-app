import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app-specific directories
      return true;
    }

    // Android permissions
    if (Platform.isAndroid) {
      // Check Android version and request appropriate permissions
      // For Android 11+ (API 30+), we need MANAGE_EXTERNAL_STORAGE
      // For older versions, we need READ/WRITE_EXTERNAL_STORAGE

      // First try storage permission
      var status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      }

      // Request storage permission
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 11+, try manage external storage
      var manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isGranted) {
        return true;
      }

      manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }

    return true;
  }

  static Future<bool> hasStoragePermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        return true;
      }

      final manageStatus = await Permission.manageExternalStorage.status;
      return manageStatus.isGranted;
    }

    return true;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
