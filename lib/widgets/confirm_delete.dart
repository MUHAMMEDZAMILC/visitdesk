import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_exception.dart';
import '../core/utils/snackbar_helper.dart';
import '../data/models/visitor.dart';
import '../providers/visitor_provider.dart';

/// Asks for confirmation, deletes, and reports the outcome.
/// Returns true when the visitor was deleted.
Future<bool> confirmAndDelete(BuildContext context, Visitor visitor) async {
  final provider = context.read<VisitorProvider>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete visitor?'),
      content: Text('${visitor.name} will be permanently removed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  try {
    await provider.deleteVisitor(visitor.id);
    if (context.mounted) SnackbarHelper.success(context, 'Visitor deleted');
    return true;
  } on ApiException catch (e) {
    if (context.mounted) SnackbarHelper.error(context, e.message);
    return false;
  }
}
