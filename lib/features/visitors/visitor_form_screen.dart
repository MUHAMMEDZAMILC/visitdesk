import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/visitor_options.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/models/visitor.dart';
import '../../providers/visitor_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Register (visitorId == null) or edit an existing visitor.
class VisitorFormScreen extends StatefulWidget {
  final String? visitorId;

  const VisitorFormScreen({super.key, this.visitorId});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _purpose = TextEditingController();
  String? _type;
  String? _project;
  Visitor? _existing;
  bool _saving = false;

  bool get _isEdit => widget.visitorId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _existing = context.read<VisitorProvider>().getVisitorById(
        widget.visitorId!,
      );
      final v = _existing;
      if (v != null) {
        _name.text = v.name;
        _mobile.text = v.mobile;
        _email.text = v.email ?? '';
        _purpose.text = v.purpose;
        _type = v.visitorType;
        _project = v.project;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final provider = context.read<VisitorProvider>();
    final email = _email.text.trim();
    try {
      if (_isEdit) {
        final updated = _existing!.copyWith(
          name: _name.text.trim(),
          mobile: _mobile.text.trim(),
          email: email,
          visitorType: _type,
          project: _project,
          purpose: _purpose.text.trim(),
        );
        await provider.updateVisitor(updated);
        if (!mounted) return;
        SnackbarHelper.success(context, 'Visitor updated');
        context.pop();
      } else {
        final draft = Visitor(
          id: '',
          name: _name.text.trim(),
          mobile: _mobile.text.trim(),
          email: email.isEmpty ? null : email,
          visitorType: _type!,
          project: _project!,
          purpose: _purpose.text.trim(),
          status: VisitorStatus.registered,
          createdAt: DateTime.now(),
        );
        final created = await provider.createVisitor(draft);
        if (!mounted) return;
        SnackbarHelper.success(context, 'Visitor registered successfully');
        // Replace the form with the details screen (shows the QR code).
        context.pushReplacement('/visitors/${created.id}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        SnackbarHelper.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit && _existing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Visitor')),
        body: const Center(child: Text('Visitor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Visitor' : 'Register Visitor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _name,
                  label: 'Visitor Name',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  controller: _mobile,
                  label: 'Mobile Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: Validators.mobile,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  controller: _email,
                  label: 'Email (optional)',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.optionalEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Visitor Type',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: VisitorOptions.types
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v),
                  validator: (v) => v == null ? 'Select visitor type' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _project,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                  items: VisitorOptions.projects
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _project = v),
                  validator: (v) => v == null ? 'Select a project' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  controller: _purpose,
                  label: 'Purpose of Visit',
                  icon: Icons.notes_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.required(v, 'Purpose'),
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomButton(
                  label: _isEdit ? 'Save Changes' : 'Register Visitor',
                  isLoading: _saving,
                  onPressed: _save,
                ),
                const SizedBox(height: AppSpacing.sm),
                CustomButton(
                  label: 'Cancel',
                  outlined: true,
                  onPressed: _saving ? null : () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
