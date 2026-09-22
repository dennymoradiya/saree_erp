import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChallanItemShareData {
  const ChallanItemShareData({
    required this.productName,
    required this.sku,
    this.colorName,
    required this.targetQuantity,
    required this.sareeSupplied,
    required this.laceSupplied,
    required this.blouseSupplied,
    this.sareePending = 0.0,
    this.lacePending = 0.0,
    this.blousePending = 0.0,
    this.requiresLace = true,
    this.requiresBlouse = true,
  });

  final String productName;
  final String sku;
  final String? colorName;
  final double targetQuantity;
  final double sareeSupplied;
  final double laceSupplied;
  final double blouseSupplied;
  final double sareePending;
  final double lacePending;
  final double blousePending;
  final bool requiresLace;
  final bool requiresBlouse;
}

class WhatsAppShareHelper {
  WhatsAppShareHelper._();

  static String formatChallanMessage({
    required String challanNumber,
    required DateTime createdAt,
    required String supplierName,
    required String stitchingUserName,
    String? notes,
    required List<ChallanItemShareData> items,
  }) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
    final buffer = StringBuffer();

    buffer.writeln('📋 *SAREE SUTRA ERP — MATERIAL CHALLAN*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📄 *Challan No:* $challanNumber');
    buffer.writeln('📅 *Date:* $dateStr');
    buffer.writeln('🏢 *Supplier:* $supplierName');
    buffer.writeln('🪡 *Stitching Unit (Manufacturer):* $stitchingUserName');
    if (notes != null && notes.trim().isNotEmpty) {
      buffer.writeln('📝 *Notes:* ${notes.trim()}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📦 *DISPATCHED ITEMS & MATERIALS:*');

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final color = item.colorName != null && item.colorName!.isNotEmpty
          ? ' (${item.colorName})'
          : '';
      buffer.writeln('');
      buffer.writeln('*${i + 1}. ${item.productName} — ${item.sku}$color*');
      buffer.writeln('   • Target Sarees: ${item.targetQuantity.toInt()}');
      buffer.writeln('   • Base Saree Fabric Delivered: ${item.sareeSupplied.toInt()} pcs');

      if (item.requiresLace) {
        buffer.writeln('   • Lace Delivered: ${item.laceSupplied.toInt()} pcs');
      }
      if (item.requiresBlouse) {
        buffer.writeln('   • Blouse Delivered: ${item.blouseSupplied.toInt()} pcs');
      }

      // Check if any material is pending in this set
      final hasShortage = item.sareePending > 0 ||
          (item.requiresLace && item.lacePending > 0) ||
          (item.requiresBlouse && item.blousePending > 0);

      if (hasShortage) {
        buffer.writeln('   ⚠️ *Pending Shortage:*');
        if (item.sareePending > 0) {
          buffer.writeln('     - Saree Fabric Pending (from Admin): ${item.sareePending.toInt()} pcs');
        }
        if (item.requiresLace && item.lacePending > 0) {
          buffer.writeln('     - Lace Pending (from Supplier): ${item.lacePending.toInt()} pcs');
        }
        if (item.requiresBlouse && item.blousePending > 0) {
          buffer.writeln('     - Blouse Pending (from Supplier): ${item.blousePending.toInt()} pcs');
        }
      }
    }

    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('✅ *Verified via Saree Sutra Material Accounting*');

    return buffer.toString();
  }

  static Future<bool> shareToWhatsApp({
    String? phoneNumber,
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);
    String urlString;

    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      urlString = 'https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage';
    } else {
      urlString = 'https://api.whatsapp.com/send?text=$encodedMessage';
    }

    final uri = Uri.parse(urlString);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
