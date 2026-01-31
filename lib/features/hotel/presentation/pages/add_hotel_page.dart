import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/utils/snackbar_utils.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddHotelPage extends ConsumerStatefulWidget {
  const AddHotelPage({super.key});

  @override
  ConsumerState<AddHotelPage> createState() => _AddHotelPageState();
}

class _AddHotelPageState extends ConsumerState<AddHotelPage> {
  final _formKey = GlobalKey<FormState>();
  final _hotelNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _availableRoomsController = TextEditingController();

  double _rating = 0.0;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  String? _uploadedImageUrl;

  Future<bool> _userPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  //code for camera
  Future<void> _cameraPicture() async {
    final hasPermission = await _userPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });

      // Upload image to server and store the URL
      await _uploadImageToServer(File(photo.path));
    }
  }

  //code for gallery
  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(image);
        });

        // Upload image to server and store the URL
        await _uploadImageToServer(File(image.path));
      }
    } on PlatformException catch (e) {
      debugPrint("Gallery PlatformException: $e");
      if (e.code == 'photo_access_denied') {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            "Please grant photo library access in settings",
          );
        }
      }
    } catch (e) {
      debugPrint("Gallery Error: $e");
      // Only show error if it's actually a permission issue
      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            "Could not access your gallery, Please check permissions",
          );
        }
      }
    }
  }

  // New method to upload image and store the URL
  Future<void> _uploadImageToServer(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      await ref.read(hotelViewmodelProvider.notifier).uploadImage(imageFile);

      // Get the uploaded image URL from state
      final state = ref.read(hotelViewmodelProvider);

      if (state.status == HotelStatus.loaded && state.uploadImageName != null) {
        setState(() {
          _uploadedImageUrl = state.uploadImageName; // STORE IT HERE
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (state.status == HotelStatus.error) {
        setState(() {
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to upload image'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  //code for video
  Future<void> _pickVideo() async {
    try {
      final hasPermission = await _userPermission(Permission.camera);
      if (!hasPermission) return;

      final hasMicPermission = await _userPermission(Permission.microphone);
      if (!hasMicPermission) return;

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1),
      );

      if (video != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(video);
        });
      }
    } catch (e) {
      _showPermissionDeniedDialog();
    }
  }

  //code for dialogBox: showDialog for menu
  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Open Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _cameraPicture();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Open Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_chat),
                title: const Text("Capture Video"),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Give Permission'),
        content: const Text("Go to settings to use this feature"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hotelNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _availableRoomsController.dispose();
    super.dispose();
  }

  Future<void> _saveHotel() async {
    if (_formKey.currentState!.validate()) {
      if (_uploadedImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select and upload an image'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Call viewmodel to create hotel
      await ref
          .read(hotelViewmodelProvider.notifier)
          .createHotel(
            hotelName: _hotelNameController.text,
            address: _addressController.text,
            city: _cityController.text,
            country: _countryController.text,
            rating: _rating,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            price: double.tryParse(_priceController.text) ?? 0.0,
            availableRooms: int.tryParse(_availableRoomsController.text) ?? 0,
            imageUrl: _uploadedImageUrl,
          );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final currentState = ref.read(hotelViewmodelProvider);

        if (currentState.status == HotelStatus.created) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hotel added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (currentState.status == HotelStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentState.errorMessage ?? 'Failed to add hotel'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Hotel',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: (_isLoading || _isUploadingImage) ? null : _saveHotel,
            child: Text(
              'Save',
              style: TextStyle(
                color: (_isLoading || _isUploadingImage)
                    ? Colors.grey
                    : const Color(0xFF1E88E5),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Images Section
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hotel Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Image Button
                          GestureDetector(
                            onTap: _isUploadingImage ? null : _pickMedia,
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _isUploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: Colors.grey[600],
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Image',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          // Selected Images
                          if (_selectedMedia.isNotEmpty) ...[
                            Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(_selectedMedia[0].path),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Green checkmark
                                if (_uploadedImageUrl != null)
                                  Positioned(
                                    bottom: 4,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                // Close button
                                Positioned(
                                  top: 4,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMedia.clear();
                                        _uploadedImageUrl = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_uploadedImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Image uploaded: $_uploadedImageUrl',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Basic Information Section
              _buildSection(
                title: 'Basic Information',
                children: [
                  _buildLabel('Hotel Name *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _hotelNameController,
                    hintText: 'Enter hotel name',
                    prefixIcon: Icons.hotel_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hotel name';
                      }
                      if (value.length < 2) {
                        return 'Hotel name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descriptionController,
                    hintText: 'Enter hotel description',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Rating'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_outline, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _rating == 0
                                        ? 'No rating'
                                        : '${_rating.toStringAsFixed(1)} Stars',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < _rating.floor()
                                            ? Icons.star
                                            : index < _rating
                                            ? Icons.star_half
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _rating,
                                min: 0,
                                max: 5,
                                divisions: 10,
                                activeColor: const Color(0xFF1E88E5),
                                onChanged: (value) {
                                  setState(() {
                                    _rating = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Location Section
              _buildSection(
                title: 'Location',
                children: [
                  _buildLabel('Address *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _addressController,
                    hintText: 'Enter full address',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      if (value.length < 5) {
                        return 'Address must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('City *'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _cityController,
                              hintText: 'City',
                              prefixIcon: Icons.location_city_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 2) {
                                  return 'Min 2 chars';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Country *'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _countryController,
                              hintText: 'Country',
                              prefixIcon: Icons.public_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 2) {
                                  return 'Min 2 chars';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Pricing & Availability Section
              _buildSection(
                title: 'Pricing & Availability',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price per Night *'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _priceController,
                              hintText: '0.00',
                              prefixIcon: Icons.currency_rupee_rounded,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price < 0) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Available Rooms *'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _availableRoomsController,
                              hintText: '0',
                              prefixIcon: Icons.meeting_room_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final rooms = int.tryParse(value);
                                if (rooms == null || rooms < 0) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isUploadingImage)
                        ? null
                        : _saveHotel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isUploadingImage
                                ? 'Uploading Image...'
                                : 'Add Hotel',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600], size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
