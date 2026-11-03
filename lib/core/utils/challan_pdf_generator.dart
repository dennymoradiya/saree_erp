import 'dart:typed_data';
import 'package:flutter/material.dart'
    show BuildContext, ScaffoldMessenger, SnackBar, Text;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

class ChallanPdfParams {
  const ChallanPdfParams({
    required this.challan,
    required this.items,
    required this.supplierName,
    required this.stitchingUserName,
    this.stitchingUserPhone,
    required this.supplierTransactions,
    required this.productionTransactions,
  });

  final Challan challan;
  final List<ChallanItem> items;
  final String supplierName;
  final String stitchingUserName;
  final String? stitchingUserPhone;
  final List<SupplierMaterialTransaction> supplierTransactions;
  final List<MaterialTransaction> productionTransactions;
}

class ChallanPdfGenerator {
  ChallanPdfGenerator._();

  /// Generates the complete multi-page PDF document bytes.
  ///
  /// Page 1: Challan header, products breakdown, material requirements & returns summary.
  /// Page 2+: Detailed transaction history (material delivery events & return records).
  static Future<Uint8List> generatePdfBytes(ChallanPdfParams params) async {
    final pdf = pw.Document(
      title: 'Challan_${params.challan.challanNumber}',
      author: 'Saree Sutra',
    );

    final fontBold = pw.Font.helveticaBold();
    final fontRegular = pw.Font.helvetica();
    final fontOblique = pw.Font.helveticaOblique();

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final dateOnlyFormat = DateFormat('dd MMM yyyy');

    // PAGE 1: Products & Return Products Summary
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Header banner
              _buildHeaderBanner(params, dateFormat, fontBold, fontRegular),
              pw.SizedBox(height: 12),

              // Parties Card
              _buildPartiesCard(params, fontBold, fontRegular),
              pw.SizedBox(height: 14),

              // Products & Material Deliveries Breakdown
              pw.Text(
                '1. Products & Material Requirements',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              _buildProductsTable(params.items, fontBold, fontRegular),
              pw.SizedBox(height: 14),

              // Stitching Production & Return Summary
              pw.Text(
                '2. Finished Saree Production & Returns Summary',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                  color: PdfColors.indigo900,
                ),
              ),
              pw.SizedBox(height: 6),
              _buildProductionSummaryTable(params.items, fontBold, fontRegular),

              pw.Spacer(),

              // Notes & Signatures
              if (params.challan.notes != null &&
                  params.challan.notes!.trim().isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        'Notes: ',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          params.challan.notes!,
                          style: pw.TextStyle(
                            font: fontOblique,
                            fontSize: 9,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              _buildSignaturesSection(fontBold, fontRegular),
              pw.SizedBox(height: 8),

              // Page 1 Footer
              _buildPageFooter(1, 2, fontRegular, dateOnlyFormat),
            ],
          );
        },
      ),
    );

    // PAGE 2+: Transaction Data
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DELIVERY CHALLAN #${params.challan.challanNumber} — TRANSACTION AUDIT TRAIL',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 9,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  'Created: ${dateOnlyFormat.format(params.challan.createdAt)}',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return _buildPageFooter(
            context.pageNumber,
            context.pagesCount,
            fontRegular,
            dateOnlyFormat,
          );
        },
        build: (pw.Context context) {
          return [
            // Section A: Supplier Material Deliveries History
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Raw Material Deliveries Audit (${params.supplierTransactions.length} transaction entries)',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.brown900,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            _buildMaterialDeliveriesSection(
              params,
              dateFormat,
              fontBold,
              fontRegular,
              fontOblique,
            ),
            pw.SizedBox(height: 18),

            // Section B: Finished Production Returns History
            pw.Text(
              'Finished Saree Production Returns (${params.productionTransactions.length} return events)',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 12,
                color: PdfColors.purple900,
              ),
            ),
            pw.SizedBox(height: 6),
            _buildProductionTransactionsTable(
              params,
              dateFormat,
              fontBold,
              fontRegular,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Downloads or shares the generated PDF.
  static Future<void> downloadOrSharePdf(
    BuildContext context,
    ChallanPdfParams params,
  ) async {
    try {
      final bytes = await generatePdfBytes(params);
      final filename =
          'Challan_${params.challan.challanNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  /// Opens the native Print & PDF Preview dialog.
  static Future<void> previewOrPrintPdf(
    BuildContext context,
    ChallanPdfParams params,
  ) async {
    try {
      final bytes = await generatePdfBytes(params);
      final filename =
          'Challan_${params.challan.challanNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: filename,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error preparing print preview: $e')),
        );
      }
    }
  }

  // --- Subcomponents for Page 1 ---

  static pw.Widget _buildHeaderBanner(
    ChallanPdfParams params,
    DateFormat dateFormat,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    PdfColor statusColor = PdfColors.blue800;
    if (params.challan.status == ChallanStatus.completed) {
      statusColor = PdfColors.green800;
    } else if (params.challan.status == ChallanStatus.cancelled) {
      statusColor = PdfColors.red800;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SAREE SUTRA ERP',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.indigo900,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'MATERIAL DELIVERY & PRODUCTION CHALLAN',
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 9,
                  color: PdfColors.grey700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    params.challan.challanNumber,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 15,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: pw.BoxDecoration(
                      color: statusColor,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      params.challan.status.displayName.toUpperCase(),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 9,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Date: ${dateFormat.format(params.challan.createdAt)}',
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartiesCard(
    ChallanPdfParams params,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ISSUED BY (SUPPLIER):',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  params.supplierName,
                  style: pw.TextStyle(font: fontBold, fontSize: 11),
                ),
                pw.Text(
                  'Supplier ID: ${params.challan.supplierId}',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            height: 36,
            width: 1,
            color: PdfColors.grey300,
            margin: const pw.EdgeInsets.symmetric(horizontal: 12),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DELIVERED TO (STITCHING / MANUFACTURER):',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  params.stitchingUserName,
                  style: pw.TextStyle(font: fontBold, fontSize: 11),
                ),
                if (params.stitchingUserPhone != null &&
                    params.stitchingUserPhone!.isNotEmpty)
                  pw.Text(
                    'Phone: ${params.stitchingUserPhone}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  )
                else
                  pw.Text(
                    'Manufacturer ID: ${params.challan.stitchingUserId}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProductsTable(
    List<ChallanItem> items,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    const tableHeaders = [
      '#',
      'Product & Color Variant',
      'Target\nSarees',
      'Saree Fabric\n(Delivered / Pend)',
      'Lace Pieces\n(Delivered / Pend)',
      'Blouse Pieces\n(Delivered / Pend)',
    ];

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: tableHeaders.map((header) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            child: pw.Text(
              header,
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: header == '#' || header.contains('Product')
                  ? pw.TextAlign.left
                  : pw.TextAlign.center,
            ),
          );
        }).toList(),
      ),
    ];

    double totalTarget = 0;
    double totalSareeDelivered = 0;
    double totalSareePending = 0;
    double totalLaceDelivered = 0;
    double totalLacePending = 0;
    double totalBlouseDelivered = 0;
    double totalBlousePending = 0;

    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      totalTarget += it.sareeIssuedQuantity;
      totalSareeDelivered += it.sareeSuppliedQuantity;
      totalSareePending += it.sareePendingSupplierQuantity;
      totalLaceDelivered += it.laceSuppliedQuantity;
      totalLacePending += it.lacePendingSupplierQuantity;
      totalBlouseDelivered += it.blouseSuppliedQuantity;
      totalBlousePending += it.blousePendingSupplierQuantity;

      final colorStr = it.colorNameSnapshot != null &&
              it.colorNameSnapshot!.trim().isNotEmpty
          ? ' • ${it.colorNameSnapshot}'
          : '';

      final sareeCell =
          '${it.sareeSuppliedQuantity.toInt()} / ${it.sareePendingSupplierQuantity.toInt()}';
      final laceCell = it.laceRequiredQuantity > 0
          ? '${it.laceSuppliedQuantity.toInt()} / ${it.lacePendingSupplierQuantity.toInt()}'
          : '-';
      final blouseCell = it.blouseRequiredQuantity > 0
          ? '${it.blouseSuppliedQuantity.toInt()} / ${it.blousePendingSupplierQuantity.toInt()}'
          : '-';

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i % 2 == 0 ? PdfColors.white : PdfColors.grey50,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${i + 1}',
                style: pw.TextStyle(font: fontRegular, fontSize: 8),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${it.productNameSnapshot}$colorStr',
                    style: pw.TextStyle(font: fontBold, fontSize: 8.5),
                  ),
                  pw.Text(
                    'SKU: ${it.skuSnapshot}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 7.5,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${it.sareeIssuedQuantity.toInt()}',
                style: pw.TextStyle(font: fontBold, fontSize: 8.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                sareeCell,
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 8,
                  color: it.sareePendingSupplierQuantity > 0
                      ? PdfColors.deepOrange800
                      : PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                laceCell,
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 8,
                  color: it.lacePendingSupplierQuantity > 0
                      ? PdfColors.deepOrange800
                      : PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                blouseCell,
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 8,
                  color: it.blousePendingSupplierQuantity > 0
                      ? PdfColors.deepOrange800
                      : PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // Totals row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(''),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'TOTALS',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalTarget.toInt()}',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalSareeDelivered.toInt()} / ${totalSareePending.toInt()}',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalLaceDelivered.toInt()} / ${totalLacePending.toInt()}',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalBlouseDelivered.toInt()} / ${totalBlousePending.toInt()}',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(18),
        1: pw.FlexColumnWidth(3.0),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(1.8),
        4: pw.FlexColumnWidth(1.8),
        5: pw.FlexColumnWidth(1.8),
      },
      children: rows,
    );
  }

  static pw.Widget _buildProductionSummaryTable(
    List<ChallanItem> items,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    const headers = [
      '#',
      'Product & SKU',
      'Target Sarees',
      'Finished Sarees Returned',
      'Pending to Return',
      'Status / Progress',
    ];

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: headers.map((h) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            child: pw.Text(
              h,
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: h == '#' || h.contains('Product')
                  ? pw.TextAlign.left
                  : pw.TextAlign.center,
            ),
          );
        }).toList(),
      ),
    ];

    double totalTarget = 0;
    double totalReturned = 0;
    double totalPending = 0;

    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      totalTarget += it.sareeIssuedQuantity;
      totalReturned += it.sareeReturnedQuantity;
      totalPending += it.sareePendingQuantity;

      final pct = it.sareeIssuedQuantity > 0
          ? ((it.sareeReturnedQuantity / it.sareeIssuedQuantity) * 100)
              .toStringAsFixed(0)
          : '0';

      final isComplete = it.sareePendingQuantity <= 0;

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i % 2 == 0 ? PdfColors.white : PdfColors.grey50,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${i + 1}',
                style: pw.TextStyle(font: fontRegular, fontSize: 8),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${it.productNameSnapshot} (${it.skuSnapshot})',
                style: pw.TextStyle(font: fontBold, fontSize: 8.5),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${it.sareeIssuedQuantity.toInt()}',
                style: pw.TextStyle(font: fontRegular, fontSize: 8.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${it.sareeReturnedQuantity.toInt()}',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 8.5,
                  color: PdfColors.green900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${it.sareePendingQuantity.toInt()}',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 8.5,
                  color:
                      isComplete ? PdfColors.grey600 : PdfColors.deepOrange900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                isComplete ? 'COMPLETED (100%)' : '$pct% ($pct of target)',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 7.5,
                  color: isComplete ? PdfColors.green800 : PdfColors.indigo900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // Totals row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'TOTAL PRODUCTION',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalTarget.toInt()}',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalReturned.toInt()}',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 8.5,
                color: PdfColors.green900,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '${totalPending.toInt()}',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 8.5,
                color: PdfColors.deepOrange900,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              totalPending <= 0
                  ? 'ALL RETURNED'
                  : '${((totalReturned / (totalTarget > 0 ? totalTarget : 1)) * 100).toInt()}% Done',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(18),
        1: pw.FlexColumnWidth(3.0),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.8),
        4: pw.FlexColumnWidth(1.8),
        5: pw.FlexColumnWidth(2.0),
      },
      children: rows,
    );
  }

  static pw.Widget _buildSignaturesSection(
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 140,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Supplier / Dispatch Authority',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
            ),
            pw.Text(
              'Authorized Signature',
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              width: 140,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Receiver / Stitching Manufacturer',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
            ),
            pw.Text(
              'Goods Received & Verified',
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Subcomponents for Page 2+ (Transaction Data) ---

  static pw.Widget _buildMaterialDeliveriesSection(
    ChallanPdfParams params,
    DateFormat dateFormat,
    pw.Font fontBold,
    pw.Font fontRegular,
    pw.Font fontOblique,
  ) {
    if (params.supplierTransactions.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'No material delivery transactions recorded yet.',
          style: pw.TextStyle(font: fontRegular, fontSize: 8.5),
        ),
      );
    }

    // Group transactions by deliveryBatchId
    final Map<String, List<SupplierMaterialTransaction>> batchMap = {};
    for (final tx in params.supplierTransactions) {
      batchMap.putIfAbsent(tx.deliveryBatchId, () => []).add(tx);
    }

    // Sort batches by createdAt descending
    final sortedBatches = batchMap.entries.toList()
      ..sort(
          (a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

    // Lookup item map
    final Map<String, ChallanItem> itemMap = {
      for (final it in params.items) it.challanItemId: it,
      for (final it in params.items) it.sku: it,
    };

    return pw.Column(
      children: sortedBatches.map((batchEntry) {
        final txs = batchEntry.value;
        final firstTx = txs.first;
        final isInitial = firstTx.allocationType == AllocationType.newChallan;

        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: isInitial ? PdfColors.blue50 : PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(
              color: isInitial ? PdfColors.blue200 : PdfColors.green200,
              width: 0.8,
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        isInitial
                            ? 'Initial Material Delivery'
                            : 'Remaining Shortage Fulfillment',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 9,
                          color: isInitial
                              ? PdfColors.blue900
                              : PdfColors.green900,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        '(${dateFormat.format(firstTx.createdAt)})',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Batch: ${firstTx.deliveryBatchId.length > 12 ? firstTx.deliveryBatchId.substring(0, 12) : firstTx.deliveryBatchId}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),

              // Deliveries table for this batch
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          'Product / Variant',
                          style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          'Material Component',
                          style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          'Delivered Qty',
                          style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ...txs.map((tx) {
                    final item = itemMap[tx.challanItemId] ?? itemMap[tx.sku];
                    final prodName = item?.productNameSnapshot ?? 'Product';
                    final color = item?.colorNameSnapshot != null &&
                            item!.colorNameSnapshot!.isNotEmpty
                        ? ' • ${item.colorNameSnapshot}'
                        : '';
                    final sku = item?.skuSnapshot ?? tx.sku;

                    String compName = 'Saree Fabric';
                    if (tx.materialType == MaterialType.lace) {
                      compName = 'Lace Pieces';
                    } else if (tx.materialType == MaterialType.blouse) {
                      compName = 'Blouse Pieces';
                    }

                    return pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.white),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            '$prodName$color ($sku)',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 7.5),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            compName,
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 7.5),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            '+${tx.quantity.toInt()} pcs',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 7.5,
                              color: PdfColors.blue900,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              if (firstTx.notes != null && firstTx.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  'Note: ${firstTx.notes}',
                  style: pw.TextStyle(
                    font: fontOblique,
                    fontSize: 7.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildProductionTransactionsTable(
    ChallanPdfParams params,
    DateFormat dateFormat,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    if (params.productionTransactions.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'No finished saree returns recorded yet.',
          style: pw.TextStyle(font: fontRegular, fontSize: 8.5),
        ),
      );
    }

    final Map<String, ChallanItem> itemMap = {
      for (final it in params.items) it.challanItemId: it,
      for (final it in params.items) it.sku: it,
    };

    const headers = [
      '#',
      'Date & Time',
      'Product & SKU',
      'Finished Sarees Returned',
      'Recorded By',
    ];

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: headers.map((h) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: pw.Text(
              h,
              style: pw.TextStyle(font: fontBold, fontSize: 8),
              textAlign: h == 'Finished Sarees Returned'
                  ? pw.TextAlign.center
                  : pw.TextAlign.left,
            ),
          );
        }).toList(),
      ),
    ];

    double totalReturned = 0;
    for (var i = 0; i < params.productionTransactions.length; i++) {
      final ptx = params.productionTransactions[i];
      totalReturned += ptx.quantity;

      final item = itemMap[ptx.challanItemId] ?? itemMap[ptx.sku];
      final prodName = item?.productNameSnapshot ?? 'Product';
      final color =
          item?.colorNameSnapshot != null && item!.colorNameSnapshot!.isNotEmpty
              ? ' • ${item.colorNameSnapshot}'
              : '';
      final sku = item?.skuSnapshot ?? ptx.sku;

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i % 2 == 0 ? PdfColors.white : PdfColors.grey50,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '${i + 1}',
                style: pw.TextStyle(font: fontRegular, fontSize: 8),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                dateFormat.format(ptx.createdAt),
                style: pw.TextStyle(font: fontRegular, fontSize: 8),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '$prodName$color ($sku)',
                style: pw.TextStyle(font: fontBold, fontSize: 8),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '+${ptx.quantity.toInt()} Sarees',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 8,
                  color: PdfColors.green900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                ptx.createdByRole.toUpperCase(),
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 7.5,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Totals row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'TOTAL SAREES RETURNED',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              '+${totalReturned.toInt()} Sarees',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 8.5,
                color: PdfColors.green900,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(18),
        1: pw.FlexColumnWidth(2.0),
        2: pw.FlexColumnWidth(3.0),
        3: pw.FlexColumnWidth(2.0),
        4: pw.FlexColumnWidth(1.2),
      },
      children: rows,
    );
  }

  static pw.Widget _buildPageFooter(
    int pageNum,
    int totalPages,
    pw.Font fontRegular,
    DateFormat dateOnlyFormat,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Saree Sutra ERP • Confidential Business Document',
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 7.5,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page $pageNum of $totalPages',
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 7.5,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
