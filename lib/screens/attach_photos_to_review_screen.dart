import 'package:flutter/material.dart';
import 'package:restofind/models/review.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restofind/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class AttachPhotosToReviewScreen extends StatefulWidget {
  final Review review;

  const AttachPhotosToReviewScreen({super.key, required this.review});

  @override
  State<AttachPhotosToReviewScreen> createState() => _AttachPhotosToReviewScreenState();
}

class _AttachPhotosToReviewScreenState extends State<AttachPhotosToReviewScreen> {
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = null;
        });

        if (kIsWeb) {
          _imageBytes = await pickedFile.readAsBytes();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _uploadPhoto() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una foto primero.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false); 
      final storageRef = FirebaseStorage.instance.ref();

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
      final String path = 'review_photos/${widget.review.id}/$fileName';
      final imageRef = storageRef.child(path);

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = imageRef.putData(_imageBytes!);
      } else {
        uploadTask = imageRef.putFile(File(_imageFile!.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await firestoreService.updateReviewImageUrls(widget.review.id, [downloadUrl]); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida y asociada a la reseña exitosamente.')),
      );

      setState(() {
        _imageFile = null;
        _imageBytes = null;
      });
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error al subir la foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la foto: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjuntar Fotos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Adjuntar fotos a: "${widget.review.restaurantName}"',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _imageFile != null
                ? Expanded(
                    child: kIsWeb
                        ? (_imageBytes != null
                            ? Image.memory(
                                _imageBytes!,
                                fit: BoxFit.contain,
                              )
                            : const Center(child: CircularProgressIndicator()))
                        : Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.contain,
                          ),
                  )
                : const Expanded(
                    child: Center(
                      child: Text('Ninguna imagen seleccionada.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _uploadPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Subir Foto'),
                  ),
          ],
        ),
      ),
    );
  }
}