import 'package:cloud_firestore/cloud_firestore.dart'; // Importation de Firestore pour accéder aux bases de données.
import 'package:firebase_auth/firebase_auth.dart'; // Importation de Firebase Auth pour l'authentification des utilisateurs.
import 'package:flutter/material.dart'; // Importation de Flutter pour construire l'interface utilisateur.
import 'package:intl/intl.dart'; // Importation de la bibliothèque Intl pour le formatage des dates.

/// Classe représentant la page des notifications des utilisateurs.
class Customernotifications extends StatefulWidget {
  const Customernotifications({Key? key}) : super(key: key);

  @override
  _CustomernotificationsState createState() => _CustomernotificationsState();
}

class _CustomernotificationsState extends State<Customernotifications> {
  String? currentUid; // Identifiant de l'utilisateur courant.
  bool isAdmin = false; // Indique si l'utilisateur est un administrateur.

  /// Récupère l'identifiant de l'utilisateur courant et vérifie s'il est un administrateur.
  Future<void> _getCurrentUid() async {
    User? user = FirebaseAuth.instance.currentUser; // Obtient l'utilisateur courant.
    if (user != null) {
      setState(() {
        currentUid = user.uid; // Stocke l'identifiant de l'utilisateur courant.
      });
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins') // Accède à la collection des administrateurs.
          .doc(currentUid) // Récupère le document correspondant à l'utilisateur courant.
          .get();
      setState(() {
        // Vérifie si le document existe et si l'utilisateur est un administrateur.
        isAdmin = adminDoc.exists && adminDoc.get('isAdmin') == true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUid(); // Appelle la méthode pour récupérer l'identifiant de l'utilisateur.
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      // Affiche un indicateur de chargement si l'identifiant de l'utilisateur n'est pas encore récupéré.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0), // Ajoute des marges autour du contenu.
        child: StreamBuilder<QuerySnapshot>(
          // Utilise un StreamBuilder pour écouter les notifications en temps réel.
          stream: isAdmin
              ? FirebaseFirestore.instance
              .collection("message_send_by_user")
              .where('read', isEqualTo: false) // Filtre les notifications non lues.
              .orderBy('timestamp', descending: true) // Trie par timestamp décroissant.
              .snapshots()
              : FirebaseFirestore.instance
              .collection("message_send_by_user")
              .where('userId', isEqualTo: currentUid) // Filtre par ID de l'utilisateur courant.
              .where('read', isEqualTo: false) // Filtre les notifications non lues.
              .orderBy('timestamp', descending: true) // Trie par timestamp décroissant.
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Affiche une erreur si la requête échoue.
              _showMessage(context, "Erreur Firebase: ${snapshot.error}");
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Affiche un indicateur de chargement pendant que les données sont en attente.
              return const Center(child: CircularProgressIndicator());
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs; // Récupère les documents de notifications.
            if (docs.isEmpty) {
              // Affiche un message si aucune notification n'est trouvée.
              return const Center(child: Text("Aucune notification reçue pour le moment"));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                // Pour chaque notification, construit une carte de notification.
                Map<String, dynamic> notification = docs[index].data() as Map<String, dynamic>;
                DateTime dateTime = (notification['timestamp'] as Timestamp).toDate(); // Convertit le timestamp en DateTime.
                String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime); // Formate la date.

                return Card(
                  elevation: 5, // Ajoute une ombre à la carte.
                  margin: const EdgeInsets.symmetric(vertical: 10), // Ajoute des marges verticales.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Arrondit les coins de la carte.
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0), // Ajoute du rembourrage à l'intérieur de la carte.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'De: Administrateur', // Affiche l'expéditeur de la notification.
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${notification['message'] ?? 'Pas de message'}', // Affiche le message de la notification.
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reçu le: $formattedDate', // Affiche la date de réception.
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _markAsRead(docs[index].id), // Marque la notification comme lue.
                              child: const Text('Marquer comme lu'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Affiche un message dans une Snackbar.
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Marque la notification comme lue dans Firestore.
  void _markAsRead(String notificationId) {
    FirebaseFirestore.instance.collection('message_send_by_user').doc(notificationId).update({
      'read': true, // Met à jour le champ 'read' à true.
    }).then((_) {
      // Affiche un message de confirmation après la mise à jour.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification marquée comme lue')),
      );
    }).catchError((error) {
      // Affiche une erreur si la mise à jour échoue.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    });
  }
}
