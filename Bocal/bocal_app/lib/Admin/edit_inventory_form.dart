import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class EditInventoryForm extends StatefulWidget {
  // stock les inventaires sous forme de clé et valeur
  final Map<String, dynamic> item;

  const EditInventoryForm({Key? key, required this.item}) : super(key: key);

  @override
  _EditInventoryFormState createState() => _EditInventoryFormState();
}

class _EditInventoryFormState extends State<EditInventoryForm> {
  final _formKey = GlobalKey<FormState>(); // Identification du formulaire dans Flutter
  // Controlleur des champs à saisir
  late TextEditingController _nameController;
  late TextEditingController _initialQuantityController;
  late TextEditingController _remainingQuantityController;
  bool _isAvailable = false;
  File? _image;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    // Initialisation des champs à saisir avec les données pré-remplir
    _nameController = TextEditingController(text: widget.item['name']);
    _initialQuantityController = TextEditingController(text: widget.item['initialQuantity'].toString());
    _remainingQuantityController = TextEditingController(text: widget.item['remainingQuantity'].toString());
    _isAvailable = widget.item['isAvailable'] ?? false;
    if (widget.item['image'] != null) {
      _imageBytes = (widget.item['image'] as Blob).bytes;
    }
  }

  Future<void> _getImage() async {
    // Création d'une instance d'ImagePicker pour accéder à la galerie.
    final ImagePicker picker = ImagePicker();

    // Ouvre la galerie et permet à l'utilisateur de choisir une image.
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    // Si l'utilisateur a sélectionné une image, on met à jour l'état avec l'image choisie.
    if (pickedFile != null) {
      setState(() {
        // Affecte l'image choisie au chemin spécifié.
        _image = File(pickedFile.path);
        // Réinitialise `_imageBytes` à null pour éviter les conflits.
        _imageBytes = null;
      });
    }
  }

  @override
  void dispose() {
    // Libération des données
    _nameController.dispose();
    _initialQuantityController.dispose();
    _remainingQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier un objet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue, Colors.lightBlue.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(),
                SizedBox(height: 24),
                _buildInfoSection(),
                SizedBox(height: 24),
                _buildQuantitySection(),
                SizedBox(height: 24),
                _buildAvailabilitySection(),
                SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Image de l\'objet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _imageBytes != null || _image != null ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!, height: 200, width: double.infinity, fit: BoxFit.cover)
                  : Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
            ) : Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Changer l\'image', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nom de l'objet",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.inventory, color: Colors.lightBlue),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(),
              validator: (value) => value?.isEmpty ?? true ? 'Veuillez saisir un nom' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantités', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            // Champs à remplir
            TextFormField(
              controller: _initialQuantityController,
              decoration: InputDecoration(
                labelText: 'Quantité initiale',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.add_box, color: Colors.lightBlue),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(),
              keyboardType: TextInputType.number,
              // affichage d'un message d'erreur si l'admin ne saisir aucune donnée
              validator: (value) => value?.isEmpty ?? true ? 'Veuillez saisir une quantité' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _remainingQuantityController,
              decoration: InputDecoration(
                labelText: 'Quantité restante',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.inventory, color: Colors.lightBlue),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Veuillez saisir une quantité' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Disponible", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            // Choix entre la disponibilité et l'indisponibilité
            Switch(
              value: _isAvailable,
              onChanged: (bool value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              activeColor: Colors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveChanges,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('Enregistrer les modifications', style: GoogleFonts.poppins(fontSize: 18)),
    );
  }

  void _saveChanges() async {
    // Si le formulaire est valide, exécuter l'action
    if (_formKey.currentState!.validate()) {
      try {
        // verification si l'image sélectionné est nul si oui garde l'image précendente
        // "Uint8List" permet de stocker une image sous forme de byte
        // "readAsBytes" permet de lire l'image en byte
        // Le point d'exclamation ! après _image indique que l'on sait que cette variable n'est pas null
        Uint8List? updatedImageBytes = _image != null ? await _image!.readAsBytes() : _imageBytes;
        // Mise à jour de la collection inventaire avec les nouvelles données
        await FirebaseFirestore.instance.collection('inventory').doc(widget.item['id']).update({
          'name': _nameController.text,
          'initialQuantity': int.parse(_initialQuantityController.text),
          'remainingQuantity': int.parse(_remainingQuantityController.text),
          'isAvailable': _isAvailable,
          'image': updatedImageBytes != null ? Blob(updatedImageBytes) : widget.item['image'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modifications enregistrées avec succès', style: GoogleFonts.poppins())),
        );
        // redirection à la page précédente
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement: $e', style: GoogleFonts.poppins())),
        );
      }
    }
  }
}