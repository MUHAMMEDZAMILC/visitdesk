import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/constants/visitor_options.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/visitor.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/visitor_provider.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/confirm_delete.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/visitor_card.dart';

class VisitorListScreen extends StatelessWidget {
  const VisitorListScreen({super.key});

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
    final items = p.filteredVisitors;

    Widget body;
    switch (p.loadState) {
      case LoadState.loading:
        body = const LoadingView();
      case LoadState.error:
        body = ErrorView(
          message: p.errorMessage ?? 'Failed to load visitors',
          onRetry: () => p.fetchVisitors(),
        );
      case LoadState.empty:
        body = const EmptyStateWidget(
          title: 'No visitors yet',
          subtitle: 'Tap + to register your first visitor.',
        );
      case LoadState.success:
        body = RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 80),
                    EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No matching visitors',
                      subtitle: 'Try a different name or mobile number.',
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    88,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final v = items[i];
                    return VisitorCard(
                      visitor: v,
                      onTap: () => context.push('/visitors/${v.id}'),
                      onEdit: () => context.push('/visitors/${v.id}/edit'),
                      onDelete: () => confirmAndDelete(context, v),
                    );
                  },
                ),
        );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Visitors')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/register'),
        icon: const Icon(Icons.person_add),
        label: const Text('Register'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SearchBar(
                hintText: 'Search by name or mobile',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: p.setSearchQuery,
              ),
            ),
            if (p.isOffline) const OfflineBanner(),
            _FilterBar(provider: p),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final VisitorProvider provider;

  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          for (final s in VisitorStatus.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AppFilterChip(
                label: s.label,
                selected: provider.statusFilter == s,
                onSelected: (sel) => provider.setStatusFilter(sel ? s : null),
              ),
            ),
          for (final pr in VisitorOptions.projects)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AppFilterChip(
                label: pr,
                selected: provider.projectFilter == pr,
                onSelected: (sel) => provider.setProjectFilter(sel ? pr : null),
              ),
            ),
        ],
      ),
    );
  }
}
