import 'dart:async';
import 'dart:typed_data';

import 'package:dcc_toolkit/dcc_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mopper/l10n/strings.dart';
import 'package:mopper/src/controllers/mopper_form_controller.dart';
import 'package:mopper/src/form_builder_screenshot_field.dart';
import 'package:mopper/src/models/mopper_data.dart';
import 'package:mopper/src/widgets/field_label.dart';
import 'package:mopper/src/widgets/system_diagnostics.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The feedback form containing all input fields and submit actions.
class MopperForm extends StatefulWidget {
  /// Creates a [MopperForm] with submit and discard callbacks.
  const MopperForm({
    required this.onSubmit,
    required this.onDiscard,
    this.screenshot,
    this.onAnnotated,
    this.packageInfo,
    super.key,
  });

  /// Called when the form is submitted with valid data.
  final OnMopperSubmit onSubmit;

  /// Called when the user discards the form.
  final VoidCallback onDiscard;

  /// The screenshot bytes to display and annotate.
  final Uint8List? screenshot;

  /// Called when the user produces an annotated screenshot.
  final ValueChanged<Uint8List>? onAnnotated;

  /// Optional pre-loaded package info.
  final PackageInfo? packageInfo;

  @override
  State<MopperForm> createState() => _MopperFormState();
}

class _MopperFormState extends State<MopperForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final MopperFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MopperFormController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(
      _controller.loadDiagnostics(
        Theme.of(context).platform,
        packageInfo: widget.packageInfo,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final data = _controller.buildMopperData(values);
      await widget.onSubmit(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          body: FormBuilder(
            key: _formKey,
            child: CustomScrollView(
              physics: _controller.isAnnotating
                  ? const NeverScrollableScrollPhysics()
                  : null,
              slivers: [
                SliverAppBar(
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: colorScheme.surface,
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(16),
                    child: Divider(),
                  ),
                  leading: IconButton(
                    onPressed: widget.onDiscard,
                    icon: const Icon(Icons.arrow_back),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  centerTitle: true,
                  title: Text(
                    context.mopperL10n.submitFeedbackTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: Paddings.all16,
                  sliver: DecoratedSliver(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      border: Border.all(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    sliver: SliverPadding(
                      padding: Paddings.all24,
                      sliver: SliverList.list(
                        children: [
                          FieldLabel(
                            label: context.mopperL10n.descriptionLabel,
                            required: true,
                          ),
                          Margins.vertical4,
                          FormBuilderTextField(
                            name: 'description',
                            decoration: InputDecoration(
                              hintText: context.mopperL10n.descriptionHint,
                            ),
                            minLines: 5,
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.mopperL10n.descriptionRequired;
                              }
                              return null;
                            },
                          ),
                          Margins.vertical24,
                          FormBuilderScreenshotField(
                            name: 'screenshot',
                            initialValue: widget.screenshot,
                            onAnnotated: widget.onAnnotated,
                            onAnnotatingChanged: (annotating) {
                              _controller.setAnnotating(annotating: annotating);
                            },
                          ),
                          Margins.vertical24,
                          FieldLabel(label: context.mopperL10n.categoryLabel),
                          Margins.vertical8,
                          FormBuilderChoiceChips<String>(
                            name: 'category',
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            spacing: Sizes.px8,
                            runSpacing: Sizes.px8,
                            showCheckmark: false,
                            options: [
                              FormBuilderChipOption(
                                value: 'uiux',
                                child: Text(context.mopperL10n.categoryUiUx),
                              ),
                              FormBuilderChipOption(
                                value: 'bug',
                                child: Text(context.mopperL10n.categoryBug),
                              ),
                              FormBuilderChipOption(
                                value: 'performance',
                                child: Text(
                                  context.mopperL10n.categoryPerformance,
                                ),
                              ),
                              FormBuilderChipOption(
                                value: 'feature',
                                child: Text(context.mopperL10n.categoryFeature),
                              ),
                            ],
                          ),
                          Margins.vertical24,
                          FieldLabel(label: context.mopperL10n.yourNameLabel),
                          Margins.vertical4,
                          FormBuilderTextField(
                            name: 'user',
                            decoration: InputDecoration(
                              hintText: context.mopperL10n.yourNameHint,
                            ),
                          ),
                          Margins.vertical24,
                          FieldLabel(
                            label: context.mopperL10n.feedbackTitleLabel,
                          ),
                          Margins.vertical4,
                          FormBuilderTextField(
                            name: 'title',
                            decoration: InputDecoration(
                              hintText: context.mopperL10n.feedbackTitleHint,
                            ),
                          ),
                          Margins.vertical24,
                          SystemDiagnostics(data: _controller.diagnostics),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: Paddings.horizontal16 + Paddings.vertical8,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: widget.onDiscard,
                                borderRadius: BorderRadius.circular(100),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.mopperL10n.discardButton,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Margins.horizontal16,
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(context.mopperL10n.submitButton),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
