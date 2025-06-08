import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restofind/models/restaurant.dart';
import 'package:restofind/services/firestore_service.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _foodTypesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _menuUrlController = TextEditingController(); 
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _imageFiles = [];
  final List<Uint8List> _imageBytesList = [];
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(pickedFile);
        });

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytesList.add(bytes);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (int i = 0; i < _imageFiles.length; i++) {
      final XFile imageFile = _imageFiles[i];
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final String path = 'restaurant_photos/$fileName';
      final imageRef = storageRef.child(path);

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = imageRef.putData(_imageBytesList[i]);
      } else {
        uploadTask = imageRef.putFile(File(imageFile.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> _saveRestaurant() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el nombre y la dirección del restaurante.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      List<String> imageUrls = await _uploadImages();

      List<String> foodTypes = _foodTypesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newRestaurant = Restaurant(
        id: '', 
        name: _nameController.text,
        address: _addressController.text,
        rating: double.tryParse(_ratingController.text),
        imageUrls: imageUrls,
        foodTypes: foodTypes,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        menuUrl: _menuUrlController.text.isNotEmpty ? _menuUrlController.text : null, 
      );

      await firestoreService.addRestaurant(newRestaurant);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurante añadido exitosamente.')),
      );

      _nameController.clear();
      _addressController.clear();
      _ratingController.clear();
      _foodTypesController.clear();
      _descriptionController.clear();
      _menuUrlController.clear();
      setState(() {
        _imageFiles.clear();
        _imageBytesList.clear();
      });
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error al guardar el restaurante: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el restaurante: ${e.toString()}')),
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
        title: const Text('Añadir Nuevo Restaurante'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Restaurante',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rating (ej. 4.5)',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _foodTypesController,
              decoration: const InputDecoration(
                labelText: 'Tipos de Comida (separados por comas, ej. "Italiana, Pizza")',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción del Restaurante',
                hintText: 'Una breve descripción del lugar y su ambiente...',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 15),
            TextField( 
              controller: _menuUrlController,
              decoration: const InputDecoration(
                labelText: 'URL del Menú (PDF, imagen, etc.)',
                hintText: 'https://example.com/menu.pdf',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (_imageFiles.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.memory(
                                    _imageBytesList[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_imageFiles[index].path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imageFiles.removeAt(index);
                                  if (kIsWeb) _imageBytesList.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.remove_circle, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveRestaurant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Guardar Restaurante',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
