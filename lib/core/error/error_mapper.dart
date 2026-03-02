import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorMapper {
  /// Maps various exception types to user-friendly error messages.
  static String map(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    }

    if (error is PostgrestException) {
      // Handle constrained violations and specific DB errors
      if (error.code == '23505') {
        return 'This record already exists.';
      }
      if (error.code == 'PGRST116') {
        return 'Data not found or you don\'t have permission to access it.';
      }
      // RLS Policy Violation
      if (error.code == '42501') {
        return 'You utilize this feature. Please contact support if this is an error.';
      }
      return 'Server error: ${error.message}';
    }

    if (error is AuthException) {
      return error.message;
    }

    // Generic Timeout
    if (error.toString().toLowerCase().contains('timeout')) {
      return 'The operation timed out. Please try again.';
    }

    // Default fallback
    return 'Something went wrong. Please try again.';
  }
}
