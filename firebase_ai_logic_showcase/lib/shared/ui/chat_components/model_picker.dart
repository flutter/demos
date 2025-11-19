import 'package:flutter/material.dart';
import '../../../shared/ui/app_spacing.dart';
import '../../../shared/ui/blaze_warning.dart';
import '../../../shared/models/gemini_model.dart';

class ModelPicker extends StatefulWidget {
  const ModelPicker({
    required this.selectedModel,
    required this.onSelected,
    super.key,
  });

  final GeminiModel selectedModel;
  final Function(String value) onSelected;

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  late String _selectedModelName;
  late String _selectedModelDescription;

  @override
  void initState() {
    super.initState();
    _selectedModelName = widget.selectedModel.name;
    _selectedModelDescription = widget.selectedModel.description;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownMenu(
                label: const Text('Select a Gemini Model'),
                initialSelection: _selectedModelName,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                dropdownMenuEntries: geminiModels.models.entries
                    .map(
                      (entry) =>
                          DropdownMenuEntry(value: entry.key, label: entry.key),
                    )
                    .toList(),
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedModelName = value;
                      _selectedModelDescription =
                          geminiModels[_selectedModelName].description;
                    });
                    widget.onSelected(value);
                  }
                },
              ),
              const SizedBox.square(dimension: AppSpacing.s8),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s8),
                child: Text(
                  textAlign: TextAlign.center,
                  _selectedModelDescription,
                ),
              ),
              if (_selectedModelName.contains('preview')) BlazeWarning(),
            ],
          ),
        ),
      ),
    );
  }
}
