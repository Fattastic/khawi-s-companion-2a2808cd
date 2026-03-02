import 'profile.dart';

/// Single source of truth for "base profile completeness".
///
/// Keep this intentionally minimal: it should not include driver-only fields
/// (vehicle, verification, etc.). This is used by routing gates to enforce
/// Profile -> Role flow exactly once.
bool isBaseProfileComplete(Profile? profile) {
  if (profile == null) return false;
  return profile.fullName.trim().isNotEmpty;
}
