import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF273F4F),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('Failed to fetch')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.toString().contains('401')) {
      return 'Session expired. Please login again.';
    } else if (error.toString().contains('403')) {
      return 'Access denied. You don\'t have permission for this action.';
    } else if (error.toString().contains('404')) {
      return 'Resource not found. Please try again.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return error.toString().replaceAll('Exception: ', '');
    }
  }

  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading && loadingMessage != null) {
        showInfo(context, loadingMessage);
      }

      final result = await operation();

      if (successMessage != null) {
        showSuccess(context, successMessage);
      }

      return result;
    } catch (e) {
      final errorMessage = getErrorMessage(e);
      showError(context, errorMessage);
      return null;
    }
  }
} 