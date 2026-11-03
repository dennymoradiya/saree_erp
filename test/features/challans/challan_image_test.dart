import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/utils/whatsapp_share_helper.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/create_challan_input.dart';

void main() {
  group('Challan Image Feature Tests', () {
    test('Challan model serialization and deserialization preserves imageUrl', () {
      final now = DateTime(2026, 9, 30, 10, 0);
      final challan = Challan(
        challanId: 'ch-123',
        challanNumber: 'CH-2026-000001',
        supplierId: 'supp-1',
        stitchingUserId: 'stitch-1',
        createdBy: 'user-1',
        createdByRole: 'admin',
        status: ChallanStatus.issued,
        issuedAt: now,
        createdAt: now,
        updatedAt: now,
        notes: 'Test note',
        imageUrl: 'https://storage.googleapis.com/test-bucket/challans/image1.jpg',
      );

      final json = challan.toJson();
      expect(
        json['imageUrl'],
        'https://storage.googleapis.com/test-bucket/challans/image1.jpg',
      );

      final fromJson = Challan.fromJson({
        'challanId': 'ch-123',
        'challanNumber': 'CH-2026-000001',
        'supplierId': 'supp-1',
        'stitchingUserId': 'stitch-1',
        'createdBy': 'user-1',
        'createdByRole': 'admin',
        'status': 'issued',
        'issuedAt': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'notes': 'Test note',
        'imageUrl': 'https://storage.googleapis.com/test-bucket/challans/image1.jpg',
      });

      expect(fromJson.imageUrl, challan.imageUrl);
      expect(fromJson.challanNumber, challan.challanNumber);
    });

    test('CreateChallanInput supports optional imageUrl', () {
      const input = CreateChallanInput(
        supplierId: 'supp-1',
        stitchingUserId: 'stitch-1',
        items: [],
        notes: 'Challan with image',
        imageUrl: 'https://storage.googleapis.com/test-bucket/challans/photo.jpg',
      );

      expect(
        input.imageUrl,
        'https://storage.googleapis.com/test-bucket/challans/photo.jpg',
      );
    });

    test('WhatsAppShareHelper formats message with attachment link when present', () {
      final now = DateTime(2026, 9, 30, 10, 0);
      final messageWithImage = WhatsAppShareHelper.formatChallanMessage(
        challanNumber: 'CH-2026-000001',
        createdAt: now,
        supplierName: 'ABC Textiles',
        stitchingUserName: 'Master Tailor',
        notes: 'Urgent delivery',
        imageUrl: 'https://storage.googleapis.com/test-bucket/challans/bill.jpg',
        items: [],
      );

      expect(
        messageWithImage,
        contains('📷 *Attachment:* https://storage.googleapis.com/test-bucket/challans/bill.jpg'),
      );

      final messageWithoutImage = WhatsAppShareHelper.formatChallanMessage(
        challanNumber: 'CH-2026-000002',
        createdAt: now,
        supplierName: 'ABC Textiles',
        stitchingUserName: 'Master Tailor',
        items: [],
      );

      expect(messageWithoutImage, isNot(contains('📷 *Attachment:*')));
    });
  });
}
