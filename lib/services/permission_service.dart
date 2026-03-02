import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request operation.
enum PermissionResult {
  /// Permission was granted.
  granted,

  /// Permission was denied but can be requested again.
  denied,

  /// Permission was permanently denied ("Never Ask Again" selected).
  /// User must go to app settings to enable.
  permanentlyDenied,

  /// Location services are disabled at the system level.
  serviceDisabled,
}

/// Centralized service for handling all permission requests.
/// Handles the "Never Ask Again" case by showing a dialog that guides
/// users to app settings.
class PermissionService {
  const PermissionService._();

  /// Requests location permission with proper handling of all states.
  ///
  /// If permission is permanently denied, shows a dialog explaining
  /// how to enable it in settings.
  ///
  /// Returns [PermissionResult] indicating the outcome.
  static Future<PermissionResult> requestLocationPermission(
    BuildContext context, {
    bool showSettingsDialogIfDenied = true,
  }) async {
    // First check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (showSettingsDialogIfDenied && context.mounted) {
        await _showLocationServiceDisabledDialog(context);
      }
      return PermissionResult.serviceDisabled;
    }

    // Check current permission status
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return PermissionResult.denied;
    }

    if (permission == LocationPermission.deniedForever) {
      if (showSettingsDialogIfDenied && context.mounted) {
        await _showPermissionPermanentlyDeniedDialog(
          context,
          permissionName: _getLocalizedPermissionName(context, 'location'),
        );
      }
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.granted;
  }

  /// Requests camera permission with proper handling of all states.
  static Future<PermissionResult> requestCameraPermission(
    BuildContext context, {
    bool showSettingsDialogIfDenied = true,
  }) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isDenied) {
      return PermissionResult.denied;
    }

    if (status.isPermanentlyDenied) {
      if (showSettingsDialogIfDenied && context.mounted) {
        await _showPermissionPermanentlyDeniedDialog(
          context,
          permissionName: _getLocalizedPermissionName(context, 'camera'),
        );
      }
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.granted;
  }

  /// Requests notification permission with proper handling of all states.
  static Future<PermissionResult> requestNotificationPermission(
    BuildContext context, {
    bool showSettingsDialogIfDenied = true,
  }) async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isDenied) {
      return PermissionResult.denied;
    }

    if (status.isPermanentlyDenied) {
      if (showSettingsDialogIfDenied && context.mounted) {
        await _showPermissionPermanentlyDeniedDialog(
          context,
          permissionName: _getLocalizedPermissionName(context, 'notification'),
        );
      }
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.granted;
  }

  /// Shows a dialog when location services are disabled at system level.
  static Future<void> _showLocationServiceDisabledDialog(
    BuildContext context,
  ) async {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isRtl ? 'خدمات الموقع معطلة' : 'Location Services Disabled',
        ),
        content: Text(
          isRtl
              ? 'يرجى تفعيل خدمات الموقع في إعدادات ${kIsWeb ? "المتصفح" : "جهازك"} لاستخدام هذه الميزة.'
              : 'Please enable location services in your ${kIsWeb ? "browser" : "device"} settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (!kIsWeb) {
                Geolocator.openLocationSettings();
              } else {
                // On web, we cannot open settings programmatically.
                // The dialog message already instructed them.
              }
            },
            child: Text(
              isRtl
                  ? (kIsWeb ? 'حسناً' : 'فتح الإعدادات')
                  : (kIsWeb ? 'OK' : 'Open Settings'),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog when a permission is permanently denied.
  static Future<void> _showPermissionPermanentlyDeniedDialog(
    BuildContext context, {
    required String permissionName,
  }) async {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isRtl ? 'الإذن مطلوب' : 'Permission Required',
        ),
        content: Text(
          isRtl
              ? 'لقد رفضت إذن $permissionName بشكل دائم. يرجى تمكينه في إعدادات التطبيق للمتابعة.'
              : 'You have permanently denied $permissionName permission. Please enable it in app settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (!kIsWeb) {
                openAppSettings();
              }
            },
            child: Text(
              isRtl
                  ? (kIsWeb ? 'حسناً' : 'فتح الإعدادات')
                  : (kIsWeb ? 'OK' : 'Open Settings'),
            ),
          ),
        ],
      ),
    );
  }

  /// Gets localized permission name.
  static String _getLocalizedPermissionName(
    BuildContext context,
    String permission,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    switch (permission) {
      case 'location':
        return isRtl ? 'الموقع' : 'location';
      case 'camera':
        return isRtl ? 'الكاميرا' : 'camera';
      case 'notification':
        return isRtl ? 'الإشعارات' : 'notification';
      default:
        return permission;
    }
  }

  /// Helper to get current position with permission handling.
  /// Returns null if permission is not granted.
  static Future<Position?> getCurrentPositionWithPermission(
    BuildContext context, {
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool showSettingsDialogIfDenied = true,
  }) async {
    final result = await requestLocationPermission(
      context,
      showSettingsDialogIfDenied: showSettingsDialogIfDenied,
    );

    if (result != PermissionResult.granted) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper to check if location permission is granted without requesting.
  static Future<bool> isLocationPermissionGranted() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
