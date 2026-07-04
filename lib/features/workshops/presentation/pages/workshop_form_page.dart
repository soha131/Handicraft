import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/workshop_cubit.dart';
import '../cubit/workshop_state.dart';
import '../../data/models/workshop_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkshopFormPage extends StatefulWidget {
  final WorkshopModel? existingWorkshop;

  const WorkshopFormPage({super.key, this.existingWorkshop});

  @override
  State<WorkshopFormPage> createState() => _WorkshopFormPageState();
}

class _WorkshopFormPageState extends State<WorkshopFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _toolController = TextEditingController();

  String _selectedCategory = 'Pottery';
  bool _isOnline = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _categories = [
    'Pottery',
    'Weaving',
    'Candle Making',
    'Woodwork',
    'Painting',
    'Other'
  ];

  final List<String> _toolsRequired = [];
  File? _pickedImage;
  String? _existingImageUrl;

  bool get isEditing => widget.existingWorkshop != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final w = widget.existingWorkshop!;
      _titleController.text = w.title;
      _descriptionController.text = w.description;
      _priceController.text = w.price.toString();
      _locationController.text = w.location ?? '';
      _selectedCategory = w.category;
      if (!_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }
      _isOnline = w.isOnline;
      _selectedDate = w.startDateTime;
      _selectedTime = TimeOfDay.fromDateTime(w.startDateTime);
      _toolsRequired.addAll(w.toolsRequired);
      _existingImageUrl = w.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _toolController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _addTool() {
    final tool = _toolController.text.trim();
    if (tool.isNotEmpty && !_toolsRequired.contains(tool)) {
      setState(() => _toolsRequired.add(tool));
      _toolController.clear();
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;
    
    final ownerId = authState.user.uid;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    
    final workshop = WorkshopModel(
      id: isEditing ? widget.existingWorkshop!.id : '',
      ownerId: ownerId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      isOnline: _isOnline,
      toolsRequired: _toolsRequired,
      startDateTime: _selectedDate,
      price: price,
      location: _isOnline ? null : _locationController.text.trim(),
      createdAt: isEditing ? widget.existingWorkshop!.createdAt : DateTime.now(),
      imageUrl: _existingImageUrl,
    );

    if (isEditing) {
      context.read<WorkshopCubit>().updateWorkshop(workshop, _pickedImage);
    } else {
      context.read<WorkshopCubit>().createWorkshop(workshop, _pickedImage);
    }
  }
  
  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workshop'),
        content: const Text('Are you sure you want to delete this workshop? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<WorkshopCubit>().deleteWorkshop(widget.existingWorkshop!.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<WorkshopCubit, WorkshopState>(
      listener: (context, state) {
        if (state is WorkshopError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
        if (state is WorkshopActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is WorkshopActionLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Workshop' : 'Create Workshop'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: isLoading ? null : _onDelete,
                ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                              ),
                              image: _pickedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : _existingImageUrl != null
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(_existingImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child: _pickedImage == null && _existingImageUrl == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text('Upload Workshop Photo', style: TextStyle(color: Colors.grey[500])),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          controller: _titleController,
                          labelText: 'Title',
                          hintText: 'E.g., Intro to Ceramics',
                          validator: (v) => v!.isEmpty ? 'Enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          validator: (v) => v!.isEmpty ? 'Enter description' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Category and Type row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                initialValue: _isOnline,
                                decoration: InputDecoration(
                                  labelText: 'Format',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: false, child: Text('In-person')),
                                  DropdownMenuItem(value: true, child: Text('Online')),
                                ],
                                onChanged: (v) => setState(() => _isOnline = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Date/Time and Price
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _selectDateTime,
                                borderRadius: BorderRadius.circular(14),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date & Time',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Text(
                                    DateFormat('MMM d, y, h:mm a').format(_selectedDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _priceController,
                                labelText: 'Price (\$)',
                                keyboardType: TextInputType.number,
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (!_isOnline) ...[
                          CustomTextField(
                            controller: _locationController,
                            labelText: 'Location / Address',
                            prefixIcon: Icons.location_on_outlined,
                            validator: (v) => (!_isOnline && v!.isEmpty) ? 'Enter location' : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Tools Required
                        Text('Required Tools/Materials', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _toolController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., Clay, Pottery Wheel',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onSubmitted: (_) => _addTool(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _addTool,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.all(14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: _toolsRequired.map((tool) => Chip(
                                label: Text(tool),
                                onDeleted: () => setState(() => _toolsRequired.remove(tool)),
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                deleteIconColor: AppColors.primary,
                              )).toList(),
                        ),
                        
                        const SizedBox(height: 48),
                        CustomButton(
                          text: isEditing ? 'Save Changes' : 'Create Workshop',
                          isGradient: true,
                          onPressed: isLoading ? null : _onSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const LoadingWidget(message: 'Processing...'),
                ),
            ],
          ),
        );
      },
    );
  }
}
