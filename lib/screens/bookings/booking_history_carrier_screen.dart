import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class BookingHistoryCarrierScreen extends StatefulWidget {
  const BookingHistoryCarrierScreen({super.key});

  @override
  State<BookingHistoryCarrierScreen> createState() => _BookingHistoryCarrierScreenState();
}

class _BookingHistoryCarrierScreenState extends State<BookingHistoryCarrierScreen> {
  List<BookingModel> _allBookings = [];

  Future<void> _downloadReport() async {
    if (_allBookings.isEmpty) return;
    
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Carrier Booking History Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Date', 'Status', 'Price'],
              data: _allBookings.map((b) => [
                b.id.substring(0, 8),
                b.createdAt.toString().split(' ')[0],
                b.status,
                b.price.toString()
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          StreamBuilder<List<BookingModel>>(
            stream: BookingService().getCarrierBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              final bookings = snapshot.data ?? [];
              final completedOrCancelled = bookings.where((b) => b.status == 'delivered' || b.status == 'cancelled').toList();
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _allBookings.length != completedOrCancelled.length) {
                  setState(() { _allBookings = completedOrCancelled; });
                }
              });

              if (completedOrCancelled.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('No history found.')));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final b = completedOrCancelled[i];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(b.shipperId).get(),
                      builder: (context, snap) {
                        final shipperName = snap.hasData && snap.data!.exists ? snap.data!['name'] : 'Unknown Shipper';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HistoryCard(
                            tripId: b.id.substring(0, 8).toUpperCase(),
                            route: '${b.cargoDetails['origin'] ?? ''} → ${b.cargoDetails['destination'] ?? ''}',
                            date: b.createdAt.toString().split(' ')[0],
                            price: 'TZS ${b.price}',
                            shipper: shipperName,
                            status: b.status == 'delivered' ? ChipStatus.success : ChipStatus.error,
                            statusLabel: b.status.toUpperCase(),
                          )
                        );
                      }
                    );
                  }, childCount: completedOrCancelled.length),
                ),
              );
            }
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.surfaceContainerLowest,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Booking History',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded, color: AppTheme.onSurface),
          tooltip: 'Download Report',
          onPressed: _downloadReport,
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.tripId,
    required this.route,
    required this.date,
    required this.price,
    required this.shipper,
    required this.status,
    required this.statusLabel,
  });

  final String tripId;
  final String route;
  final String date;
  final String price;
  final String shipper;
  final ChipStatus status;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tripId,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              StatusChip(label: statusLabel, status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.route_rounded,
                  size: 16, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                route,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.business_rounded,
                  size: 16, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                shipper,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
