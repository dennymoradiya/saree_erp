import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';

void main() {
  group('UserRole & AppUser Deserialization Tests', () {
    test('UserRole.fromValue handles stitching_user in various formats', () {
      expect(UserRole.fromValue('stitching_user'), equals(UserRole.stitchingUser));
      expect(UserRole.fromValue('stitchingUser'), equals(UserRole.stitchingUser));
      expect(UserRole.fromValue('stitching User'), equals(UserRole.stitchingUser));
      expect(UserRole.fromValue('STITCHING_USER'), equals(UserRole.stitchingUser));
      expect(UserRole.fromValue('admin'), equals(UserRole.admin));
      expect(UserRole.fromValue('supplier'), equals(UserRole.supplier));
      expect(UserRole.fromValue(null), equals(UserRole.admin));
    });

    test('AppUser.fromJson correctly parses Firestore document with role "stitching_user"', () {
      final json = {
        'uid': 'test-stitching-uid-123',
        'name': 'Ramesh Kumar',
        'email': 'ramesh@stitching.com',
        'role': 'stitching_user',
        'isActive': true,
        'phone': '9876543210',
        'supplierId': null,
        'stitchingUserId': 'su-456',
        'fcmToken': null,
        'createdAt': 1726912800000,
        'updatedAt': 1726912800000,
      };

      final user = AppUser.fromJson(json);
      expect(user.uid, equals('test-stitching-uid-123'));
      expect(user.role, equals(UserRole.stitchingUser));
      expect(user.stitchingUserId, equals('su-456'));
      expect(user.isActive, isTrue);

      final outJson = user.toJson();
      expect(outJson['role'], equals('stitching_user'));
    });

    test('AppUser.fromJson also parses role "stitchingUser" or "supplier"', () {
      final json1 = {
        'uid': 'u1',
        'name': 'Supplier Name',
        'email': 'sup@test.com',
        'role': 'supplier',
        'isActive': true,
        'createdAt': 1726912800000,
        'updatedAt': 1726912800000,
      };
      final user1 = AppUser.fromJson(json1);
      expect(user1.role, equals(UserRole.supplier));

      final json2 = {
        'uid': 'u2',
        'name': 'Stitching Old',
        'email': 'stitch@test.com',
        'role': 'stitchingUser',
        'isActive': true,
        'createdAt': 1726912800000,
        'updatedAt': 1726912800000,
      };
      final user2 = AppUser.fromJson(json2);
      expect(user2.role, equals(UserRole.stitchingUser));
    });
  });
}
