// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/firestore_repository.dart';

import '../../data/models.dart';
import '../theme.dart';

class JobEditScreen extends StatefulWidget {
  final String jobId;

  const JobEditScreen({required this.jobId, super.key});

  @override
  State<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<JobEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _addressController;
  late final TextEditingController _guestCountController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  DateTime? _selectedDate;
  List<String> _selectedRecipeIds = [];
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _addressController = TextEditingController();
    _guestCountController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _guestCountController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CommisColors.goldAccent,
              onPrimary: CommisColors.background,
              surface: CommisColors.surfaceLevel1,
              onSurface: CommisColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedJob = CateringJob(
        id: widget.jobId,
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        guestCount: int.tryParse(_guestCountController.text.trim()) ?? 0,
        date: _selectedDate!,
        recipeIds: _selectedRecipeIds,
        latitude: double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      );

      await context.read<FirestoreRepository>().updateJob(updatedJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CommisColors.goldAccent,
            content: Text(
              'Catering Job updated successfully!',
              style: GoogleFonts.sourceSans3(
                color: CommisColors.background,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to update job: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FirestoreRepository>();

    return Scaffold(
      backgroundColor: CommisColors.background,
      appBar: AppBar(
        backgroundColor: CommisColors.surfaceLevel1,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CommisColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EDIT CATERING JOB',
          style: GoogleFonts.outfit(
            color: CommisColors.textPrimary,
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: CommisColors.borderLowContrast, height: 1.0),
        ),
      ),
      body: StreamBuilder<CateringJob?>(
        stream: repository.watchJob(widget.jobId),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.connectionState == ConnectionState.waiting &&
              !_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: CommisColors.goldAccent),
            );
          }

          if (jobSnapshot.hasError) {
            return Center(
              child: Text(
                'Error loading job: ${jobSnapshot.error}',
                style: GoogleFonts.sourceSans3(color: Colors.redAccent),
              ),
            );
          }

          final job = jobSnapshot.data;
          if (job == null) {
            return Center(
              child: Text(
                'Job not found',
                style: GoogleFonts.sourceSans3(
                  color: CommisColors.textSecondary,
                ),
              ),
            );
          }

          if (!_isInitialized) {
            _titleController.text = job.title;
            _addressController.text = job.address;
            _guestCountController.text = job.guestCount.toString();
            _latitudeController.text = job.latitude.toString();
            _longitudeController.text = job.longitude.toString();
            _selectedDate = job.date;
            _selectedRecipeIds = List<String>.from(job.recipeIds);
            _isInitialized = true;
          }

          return StreamBuilder<List<Recipe>>(
            stream: repository.watchRecipes(),
            builder: (context, recipesSnapshot) {
              final recipes = recipesSnapshot.data ?? const <Recipe>[];

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    // Job Title
                    Text(
                      'EVENT TITLE',
                      style: GoogleFonts.outfit(
                        color: CommisColors.textSecondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.sourceSans3(
                        color: CommisColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Anniversary Party',
                        hintStyle: TextStyle(color: CommisColors.textSecondary),
                        filled: true,
                        fillColor: CommisColors.surfaceLevel1,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CommisColors.goldAccent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CommisColors.borderLowContrast,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Venue Address
                    Text(
                      'VENUE ADDRESS',
                      style: GoogleFonts.outfit(
                        color: CommisColors.textSecondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _addressController,
                      style: GoogleFonts.sourceSans3(
                        color: CommisColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Street, City, Zip Code',
                        hintStyle: TextStyle(color: CommisColors.textSecondary),
                        filled: true,
                        fillColor: CommisColors.surfaceLevel1,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CommisColors.goldAccent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CommisColors.borderLowContrast,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a venue address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Row of Guest Count & Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GUEST COUNT',
                          style: GoogleFonts.outfit(
                            color: CommisColors.textSecondary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _guestCountController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.sourceSans3(
                            color: CommisColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: CommisColors.surfaceLevel1,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: CommisColors.goldAccent,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: CommisColors.borderLowContrast,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Latitude and Longitude Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LATITUDE',
                                style: GoogleFonts.outfit(
                                  color: CommisColors.textSecondary,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _latitudeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: GoogleFonts.sourceSans3(
                                  color: CommisColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 28.538',
                                  hintStyle: TextStyle(
                                    color: CommisColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: CommisColors.surfaceLevel1,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: CommisColors.goldAccent,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: CommisColors.borderLowContrast,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LONGITUDE',
                                style: GoogleFonts.outfit(
                                  color: CommisColors.textSecondary,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _longitudeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: GoogleFonts.sourceSans3(
                                  color: CommisColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. -81.379',
                                  hintStyle: TextStyle(
                                    color: CommisColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: CommisColors.surfaceLevel1,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: CommisColors.goldAccent,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: CommisColors.borderLowContrast,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Date Selection Row
                    Text(
                      'EVENT DATE',
                      style: GoogleFonts.outfit(
                        color: CommisColors.textSecondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: CommisColors.surfaceLevel1,
                          border: Border.all(
                            color: CommisColors.borderLowContrast,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : _formatDate(_selectedDate!),
                              style: GoogleFonts.jetBrainsMono(
                                color: _selectedDate == null
                                    ? CommisColors.textSecondary
                                    : CommisColors.goldAccent,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: CommisColors.goldAccent,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Recipes Checklist
                    Text(
                      'ASSOCIATE RECIPES',
                      style: GoogleFonts.outfit(
                        color: CommisColors.textSecondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    if (recipes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No recipes available to add',
                          style: GoogleFonts.sourceSans3(
                            color: CommisColors.textSecondary.withAlpha(153),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CommisColors.borderLowContrast,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipes.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: CommisColors.borderLowContrast,
                            height: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            final isSelected = _selectedRecipeIds.contains(
                              recipe.id,
                            );

                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(
                                recipe.name,
                                style: GoogleFonts.sourceSans3(
                                  color: CommisColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                recipe.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sourceSans3(
                                  color: CommisColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                              activeColor: CommisColors.goldAccent,
                              checkColor: CommisColors.background,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedRecipeIds.add(recipe.id);
                                  } else {
                                    _selectedRecipeIds.remove(recipe.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 32.0),

                    // Actions Buttons (Cancel & Save)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSaving ? null : () => context.pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: CommisColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.sourceSans3(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        FilledButton(
                          onPressed: _isSaving ? null : _saveJob,
                          style: FilledButton.styleFrom(
                            backgroundColor: CommisColors.goldAccent,
                            foregroundColor: CommisColors.background,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: CommisColors.background,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: GoogleFonts.sourceSans3(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.0,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
