class ProfileExtension {
  final String userId;
  final List<String> roles;
  final String? city;
  final String? neighborhood;
  final List<ActivityWindow> activityWindows;
  final List<String> purposes;
  final VehicleInfo? vehicleInfo;
  final FamilyContext? familyContext;

  const ProfileExtension({
    required this.userId,
    required this.roles,
    this.city,
    this.neighborhood,
    required this.activityWindows,
    required this.purposes,
    this.vehicleInfo,
    this.familyContext,
  });

  factory ProfileExtension.fromJson(Map<String, dynamic> json) {
    return ProfileExtension(
      userId: json['user_id'] as String,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
      city: json['city'] as String?,
      neighborhood: json['neighborhood'] as String?,
      activityWindows: (json['activity_windows'] as List?)
              ?.map((e) => ActivityWindow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      purposes: (json['purposes'] as List?)?.cast<String>() ?? [],
      vehicleInfo: json['vehicle_info'] != null
          ? VehicleInfo.fromJson(json['vehicle_info'] as Map<String, dynamic>)
          : null,
      familyContext: json['family_context'] != null
          ? FamilyContext.fromJson(
              json['family_context'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'roles': roles,
        'city': city,
        'neighborhood': neighborhood,
        'activity_windows': activityWindows.map((e) => e.toJson()).toList(),
        'purposes': purposes,
        'vehicle_info': vehicleInfo?.toJson(),
        'family_context': familyContext?.toJson(),
      };
}

class ActivityWindow {
  final String window; // morning, afternoon, evening
  final List<int> days; // 1-7

  const ActivityWindow({required this.window, required this.days});

  factory ActivityWindow.fromJson(Map<String, dynamic> json) {
    return ActivityWindow(
      window: json['window'] as String,
      days: (json['days'] as List?)?.cast<int>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {'window': window, 'days': days};
}

class VehicleInfo {
  final bool ownsCar;
  final String? type;
  final bool hasAc;
  final bool hasChildSeat;
  final String condition; // excellent, good, acceptable

  const VehicleInfo({
    required this.ownsCar,
    this.type,
    required this.hasAc,
    required this.hasChildSeat,
    required this.condition,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      ownsCar: json['owns_car'] as bool? ?? false,
      type: json['type'] as String?,
      hasAc: json['has_ac'] as bool? ?? false,
      hasChildSeat: json['has_child_seat'] as bool? ?? false,
      condition: json['condition'] as String? ?? 'good',
    );
  }

  Map<String, dynamic> toJson() => {
        'owns_car': ownsCar,
        'type': type,
        'has_ac': hasAc,
        'has_child_seat': hasChildSeat,
        'condition': condition,
      };
}

class FamilyContext {
  final bool isParent;
  final bool familyDriverWilling;

  const FamilyContext({
    required this.isParent,
    required this.familyDriverWilling,
  });

  factory FamilyContext.fromJson(Map<String, dynamic> json) {
    return FamilyContext(
      isParent: json['is_parent'] as bool? ?? false,
      familyDriverWilling: json['family_driver_willing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'is_parent': isParent,
        'family_driver_willing': familyDriverWilling,
      };
}
