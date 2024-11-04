import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Form/inventory_form.dart';
import 'edit_inventory_form.dart';

class AdminInventory extends StatefulWidget {
  const AdminInventory({super.key});

  @override
  State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory> {
  // stock sous forme de liste ordonnée d'un tableau de clé et valeur
  late Future<List<Map<String, dynamic>>> _inventoryItems;

  @override
  void initState() {
    super.initState();
    // initialisation de "_inventoryItems"
    _inventoryItems = _getInventoryItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddButton(),
            SizedBox(height: 20),
            Expanded(
              child: _buildInventoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: () => _addNewItem(),
      icon: Icon(Icons.add, color: Colors.white),
      label: Center(child: Text('Ajouter un élément', style: GoogleFonts.poppins(color: Colors.white))),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildInventoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}', style: GoogleFonts.poppins()));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Aucun élément dans l'inventaire", style: GoogleFonts.poppins()));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final item = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              item['id'] = snapshot.data!.docs[index].id;
              return _buildInventoryCard(item);
            },
          );
        }
      },
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    bool isAvailable = item['isAvailable'] == true;
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // Permet d'avoir un effet lors du click
        onTap: () => _editInventoryItem(item),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemImage(item),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 4),
                    Text('Quantité initiale: ${item['initialQuantity']}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    Text('Quantité restante: ${item['remainingQuantity']}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    SizedBox(height: 8),
                    _buildAvailabilityChip(isAvailable),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteInventoryItem(item['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(Map<String, dynamic> item) {
    return ClipRRect( // permet d'arrondir les bords de l'image ou du conteneur grâce à la propriété borderRadius
      borderRadius: BorderRadius.circular(8),
      child: item['image'] != null // Vérifie si l'image existe dans les données de l'élément
          ? Image.memory( // Affiche une image à partir d'un tableau d'octets (bytes), qui est extrait de item['image']
        (item['image'] as Blob).bytes, // Le type de données Blob est utilisé pour stocker des objets binaires (comme une image).
        width: 80,
        height: 80,
        fit: BoxFit.cover, // Assure que l'image couvre toute la surface du conteneur de 80x80 pixels sans se déformer
      ) : Container( // Si l'image n'est pas présente, un conteneur gris avec une icône (image manquante) est affiché
        width: 80,
        height: 80,
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildAvailabilityChip(bool isAvailable) {
    return Chip(
      label: Text(
        isAvailable ? 'Disponible' : 'Indisponible',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: isAvailable ? Colors.green : Colors.red,
    );
  }

  void _addNewItem() async {
    // redirection vers la page du formulaire
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryForm()),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _editInventoryItem(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInventoryForm(item: item),
      ),
    );
    if (result == true) {
      setState(() {
        _inventoryItems = _getInventoryItems();
      });
    }
  }

  Future<void> _deleteInventoryItem(String itemId) async {
    // Affiche une boîte de dialogue pour confirmer la suppression.
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Crée un AlertDialog pour demander la confirmation de l'utilisateur.
        return AlertDialog(
          title: Text('Confirmer la suppression', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Êtes-vous sûr de vouloir supprimer cet élément ?', style: GoogleFonts.poppins()),
          actions: <Widget>[
            // Bouton pour annuler la suppression.
            TextButton(
              child: Text('Annuler', style: GoogleFonts.poppins()),
              onPressed: () => Navigator.of(context).pop(false), // Ferme le dialogue sans suppression.
            ),
            // Bouton pour confirmer la suppression.
            TextButton(
              child: Text('Supprimer', style: GoogleFonts.poppins(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true), // Ferme le dialogue et confirme la suppression.
            ),
          ],
        );
      },
    );

    // Si l'utilisateur a confirmé la suppression, l'élément est supprimé de Firestore.
    if (confirmDelete == true) {
      // Suppression de l'élément de la collection 'inventory' dans Firestore.
      await FirebaseFirestore.instance.collection('inventory').doc(itemId).delete();

      // Mise à jour de l'état de l'application pour rafraîchir la liste des éléments de l'inventaire.
      setState(() {
        _inventoryItems = _getInventoryItems(); // Actualisation des éléments de l'inventaire après suppression.
      });
    }
  }


  Future<List<Map<String, dynamic>>> _getInventoryItems() async {
    // Récupération de tous les documents de la collection 'inventory' dans Firestore.
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('inventory').get();

    // Transformation de chaque document en un Map contenant les données du document et son ID.
    return snapshot.docs.map((DocumentSnapshot doc) {
      // Les données du document sont stockées sous forme de Map.
      final data = doc.data() as Map<String, dynamic>;

      // L'ID du document est ajouté au Map pour référence.
      data['id'] = doc.id;

      // Retourne le Map avec les données et l'ID.
      return data;
    }).toList(); // Convertit la collection des Maps en liste.
  }

}