import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_colors.dart';

class ToastUtils {
  static final FToast _fToast = FToast();

  /// Initialize toast with context
  static void init(BuildContext context) {
    _fToast.init(context);
  }

  /// Show success toast
  static void showSuccess(String message, {int duration = 2}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show error toast
  static void showError(String message, {int duration = 3}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show warning toast
  static void showWarning(String message, {int duration = 2}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show info toast
  static void showInfo(String message, {int duration = 2}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show custom toast
  static void show(String message, {
    Color? backgroundColor,
    Color? textColor,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int duration = 2,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor ?? AppColors.surface,
      textColor: textColor ?? AppColors.textPrimary,
      fontSize: 14.0,
    );
  }

  /// Cancel all toasts
  static void cancel() {
    Fluttertoast.cancel();
  }
}
