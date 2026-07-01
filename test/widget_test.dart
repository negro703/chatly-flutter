import 'package:flutter_test/flutter_test.dart';
import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_strings.dart';

void main() {
  group('App Constants Tests', () {
    test('AppStrings should have correct app name', () {
      expect(AppStrings.appName, 'Our Chat');
    });

    test('AppColors should have correct primary color', () {
      expect(AppColors.primary.toARGB32(), 0xFF075E54);
    });
  });
}