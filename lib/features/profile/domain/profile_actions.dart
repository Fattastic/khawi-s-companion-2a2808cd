import 'package:khawi_flutter/features/profile/data/profile_repo.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';

class ProfileActions {
  ProfileActions(this._repo);

  final ProfileRepo _repo;

  Future<void> setRole(String userId, UserRole role) {
    return _repo.setRole(userId, role);
  }

  Future<void> verifyIdentity(String userId) {
    return _repo.verifyIdentity(userId);
  }

  Future<void> setVerificationStatus(
    String userId, {
    required bool isVerified,
  }) {
    return _repo.setVerificationStatus(userId, isVerified: isVerified);
  }
}
