import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/presentation/state/auth_state.dart';
import 'package:hotelspot/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final AuthEntity? user;

  const EditProfilePage({super.key, this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.user?.fullName ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2140),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Choose Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0A0E21),
                  child: Icon(Icons.camera_alt, color: Color(0xFF1E90FF)),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0A0E21),
                  child: Icon(Icons.photo_library, color: Color(0xFF1E90FF)),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request appropriate permission based on source
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission required'
                  : 'Photo permission required',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  String _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    final base = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    return '$base$imageUrl';
  }

  String _buildVersionedUrl(String? imageUrl, int version) {
    final url = _buildImageUrl(imageUrl);
    if (url.isEmpty) return '';
    return '$url?v=$version';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          fullName: _fullNameController.text.trim(),
          username: _usernameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          image: _pickedImage,
        );

    if (!mounted) return;

    final state = ref.read(authViewModelProvider);

    if (state.status == AuthStatus.profileUpdated) {
      final oldUrl = _buildImageUrl(widget.user?.imageUrl);
      final newUrl = _buildImageUrl(state.authEntity?.imageUrl);
      if (oldUrl.isNotEmpty) await NetworkImage(oldUrl).evict();
      if (newUrl.isNotEmpty) await NetworkImage(newUrl).evict();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      setState(() => _pickedImage = null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF00D084),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (state.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Update failed'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isUpdating = authState.status == AuthStatus.profileUpdating;
    final imageUrl = authState.authEntity?.imageUrl ?? widget.user?.imageUrl;
    final versionedUrl = _buildVersionedUrl(imageUrl, authState.imageVersion);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Tap avatar to show bottom sheet
              GestureDetector(
                onTap: _showImagePickerSheet,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A2140),
                        border: Border.all(
                          color: const Color(0xFF1E90FF),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : versionedUrl.isNotEmpty
                            ? Image.network(
                                versionedUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Color(0xFF1E90FF),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 48,
                                color: Color(0xFF1E90FF),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E90FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),

              const SizedBox(height: 32),

              _buildField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 2) return 'Min 2 characters';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 2) return 'Min 2 characters';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildField(
                controller: _phoneController,
                label: 'Phone Number (optional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isUpdating ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF1E90FF,
                    ).withOpacity(0.4),
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A2140),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
