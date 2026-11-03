import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ImageUploadHelper {
  ImageUploadHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Prompts user to select an image from Camera or Gallery (or directly opens file dialog on web).
  static Future<XFile?> pickImage(BuildContext context) async {
    final ImageSource? source;

    if (kIsWeb) {
      // On web browsers, directly open file/photo selection.
      // Browsers natively handle photo/gallery choices and this ensures the file dialog
      // is invoked synchronously within the user gesture cycle.
      source = ImageSource.gallery;
    } else {
      source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
                ),
                title: const Text('Take Photo (Camera)'),
                subtitle: const Text('Capture using device camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library, color: Color(0xFF1565C0)),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from photo library or files'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

    if (source == null) return null;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      return pickedFile;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return null;
    }
  }

  /// Uploads image bytes to Firebase Storage and returns download URL.
  static Future<String> uploadImage({
    required Uint8List bytes,
    required String storageFolder,
    String? customFileName,
  }) async {
    final fileName = customFileName ??
        '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.jpg';
    final storageRef =
        FirebaseStorage.instance.ref().child('$storageFolder/$fileName');

    final uploadTask = await storageRef.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Opens a full screen interactive viewer for an image (zoom & pan).
  static void viewFullScreenImage(
    BuildContext context, {
    String? imageUrl,
    Uint8List? imageBytes,
    String? title,
  }) {
    if (imageUrl == null && imageBytes == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            title: Text(title ?? 'Challan Image'),
            actions: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  tooltip: 'Open in browser',
                  onPressed: () async {
                    final uri = Uri.tryParse(imageUrl);
                    if (uri != null) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 64,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
