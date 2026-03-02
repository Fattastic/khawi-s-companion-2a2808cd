import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };
}

class EmergencyContactsService {
  static const _contactsKey = 'emergency_contacts';
  static const _autoShareKey = 'emergency_auto_share';
  static const maxContacts = 3;

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '').trim();
  }

  String _normalizeName(String name) => name.trim();

  Future<List<EmergencyContact>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contactsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final data = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_contactsKey, jsonEncode(data));
  }

  Future<void> addContact(EmergencyContact contact) async {
    final normalized = EmergencyContact(
      name: _normalizeName(contact.name),
      phone: _normalizePhone(contact.phone),
    );
    if (normalized.name.isEmpty || normalized.phone.isEmpty) return;

    final contacts = await getContacts();
    final exists = contacts.any(
      (c) => _normalizePhone(c.phone) == normalized.phone,
    );
    if (exists) return;
    if (contacts.length >= maxContacts) return;
    final updated = [...contacts, normalized];
    await saveContacts(updated);
  }

  Future<void> removeContact(String phone) async {
    final contacts = await getContacts();
    final normalized = _normalizePhone(phone);
    final updated =
        contacts.where((c) => _normalizePhone(c.phone) != normalized).toList();
    await saveContacts(updated);
  }

  Future<bool> getAutoShareEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoShareKey) ?? false;
  }

  Future<void> setAutoShareEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoShareKey, enabled);
  }
}
