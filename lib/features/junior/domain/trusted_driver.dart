import 'package:khawi_flutter/core/utils/json_readers.dart';

class TrustedDriver {
  final String id;
  final String parentId;
  final String driverId;
  final String? label;
  final bool isActive;

  TrustedDriver({
    required this.id,
    required this.parentId,
    required this.driverId,
    this.label,
    required this.isActive,
  });

  factory TrustedDriver.fromJson(Map<String, dynamic> json) {
    return TrustedDriver(
      id: readString(json, 'id'),
      parentId: readString(json, 'parent_id'),
      driverId: readString(json, 'driver_id'),
      label: readNullableString(json, 'label'),
      isActive: readBool(json, 'is_active'),
    );
  }
}
