import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/theme_provider.dart';
import '../../providers/visitor_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/offline_banner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    try {
      await context.read<VisitorProvider>().fetchVisitors(silent: true);
    } on ApiException catch (e) {
      if (context.mounted) SnackbarHelper.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VisitorProvider>();

    Widget body;
    if (p.loadState == LoadState.loading) {
      body = const LoadingView();
    } else if (p.loadState == LoadState.error) {
      body = ErrorView(
        message: p.errorMessage ?? 'Failed to load data',
        onRetry: () => p.fetchVisitors(),
      );
    } else {
      body = Column(
        children: [
          if (p.isOffline) const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  DashboardStatCard(
                    label: 'Total Visitors Today',
                    value: p.totalToday,
                    icon: Icons.groups,
                    color: AppColors.registered,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DashboardStatCard(
                    label: 'Currently Checked In',
                    value: p.checkedInNow,
                    icon: Icons.login,
                    color: AppColors.checkedIn,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DashboardStatCard(
                    label: 'Checked Out Today',
                    value: p.checkedOutToday,
                    icon: Icons.logout,
                    color: AppColors.checkedOut,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomButton(
                    label: 'Register Visitor',
                    icon: Icons.person_add_alt_1,
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomButton(
                    label: 'Scan QR Code',
                    icon: Icons.qr_code_scanner,
                    outlined: true,
                    onPressed: () => context.go('/scan'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomButton(
                    label: 'Visitor List',
                    icon: Icons.list_alt,
                    outlined: true,
                    onPressed: () => context.go('/visitors'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: context.read<ThemeProvider>().toggle,
          ),
        ],
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VisitDesk',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              'Sumadhura Group · Machine Test',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}
