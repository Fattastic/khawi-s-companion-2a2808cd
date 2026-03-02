import 'package:khawi_flutter/core/utils/json_readers.dart';

class Kid {
  final String id;
  final String parentId;
  final String name;
  final String? avatarUrl;
  final String? schoolName;
  final String? notes;

  Kid({
    required this.id,
    required this.parentId,
    required this.name,
    this.avatarUrl,
    this.schoolName,
    this.notes,
  });

  factory Kid.fromJson(Map<String, dynamic> json) {
    return Kid(
      id: readString(json, 'id'),
      parentId: readString(json, 'parent_id'),
      name: readString(json, 'name'),
      avatarUrl: readNullableString(json, 'avatar_url'),
      schoolName: readNullableString(json, 'school_name'),
      notes: readNullableString(json, 'notes'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'avatar_url': avatarUrl,
      'school_name': schoolName,
      'notes': notes,
    };
  }
}
