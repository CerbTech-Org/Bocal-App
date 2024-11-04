import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Admin/adminHome.dart';
import '../Client/CustomerHome.dart';

// Classe pour afficher le contenu basé sur le rôle de l'utilisateur
class RoleBasedContent extends StatelessWidget {
  // Identifiant de l'utilisateur
  final String userId;

  // Constructeur de la classe, nécessite un identifiant utilisateur
  RoleBasedContent({required this.userId});

  // Méthode pour vérifier si l'utilisateur est un administrateur
  Future<bool> isAdmin(String userId) async {
    // Récupère le document de l'administrateur à partir de Firestore
    final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userId).get();
    return adminDoc.exists; // Renvoie true si le document existe, sinon false
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface utilisateur
    return FutureBuilder<bool>(
      future: isAdmin(userId), // Appelle la méthode pour vérifier le rôle
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Vérifie si le future a terminé son exécution
          if (snapshot.data == true) {
            return adminHome(); // Affiche la page d'accueil de l'administrateur
          } else {
            return Studenthome(); // Affiche la page d'accueil du client
          }
        }
        // Affiche un indicateur de chargement pendant que la vérification est en cours
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
