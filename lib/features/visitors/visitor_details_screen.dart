import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/visitor.dart';
import '../../providers/visitor_provider.dart';
import '../../widgets/confirm_delete.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/status_chip.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final String visitorId;

  const VisitorDetailsScreen({super.key, required this.visitorId});

  Future<void> _act(BuildContext context, Visitor v) async {
    final p = context.read<VisitorProvider>();
    try {
      if (v.canCheckIn) {
        await p.checkIn(v.id);
        if (context.mounted) SnackbarHelper.success(context, 'Checked in');
      } else if (v.canCheckOut) {
        await p.checkOut(v.id);
        if (context.mounted) SnackbarHelper.success(context, 'Checked out');
      }
    } on ApiException catch (e) {
      if (context.mounted) SnackbarHelper.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VisitorProvider>();
    // Always read the live record so list/details/dashboard stay in sync.
    final v = p.getVisitorById(visitorId);

    if (v == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visitor Details')),
        body: const EmptyStateWidget(
          icon: Icons.person_off_outlined,
          title: 'Visitor not found',
        ),
      );
    }

    final busy = p.isBusy(v.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/visitors/${v.id}/edit'),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: busy
                ? null
                : () async {
                    if (await confirmAndDelete(context, v) && context.mounted) {
                      context.pop();
                    }
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              v.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          StatusChip(status: v.status),
                        ],
                      ),
                      const Divider(height: AppSpacing.lg),
                      _row('Mobile', v.mobile),
                      _row('Email', v.email ?? '—'),
                      _row('Type', v.visitorType),
                      _row('Project', v.project),
                      _row('Purpose', v.purpose),
                      _row('Registered', DateHelper.format(v.createdAt)),
                      _row('Check-in', DateHelper.format(v.checkInTime)),
                      _row('Check-out', DateHelper.format(v.checkOutTime)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      QrImageView(
                        data: v.id,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Visitor ID: ${v.id}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _actionButton(context, v, busy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );

  Widget _actionButton(BuildContext context, Visitor v, bool busy) {
    if (v.canCheckIn) {
      return CustomButton(
        label: 'Check In',
        icon: Icons.login,
        isLoading: busy,
        onPressed: () => _act(context, v),
      );
    }
    if (v.canCheckOut) {
      return CustomButton(
        label: 'Check Out',
        icon: Icons.logout,
        isLoading: busy,
        onPressed: () => _act(context, v),
      );
    }
    return const CustomButton(label: 'Visit completed', onPressed: null);
  }
}
