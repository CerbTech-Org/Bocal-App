import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service d'authentification gérant les opérations liées aux utilisateurs
class AuthService {
  // Instance de FirebaseAuth pour gérer l'authentification
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fonction pour gérer l'inscription d'un nouvel utilisateur
  Future<User?> signUp(String email, String password) async {
    try {
      // Crée un nouvel utilisateur avec l'email et le mot de passe fournis
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print('Utilisateur inscrit: ${result.user}');
      return result.user; // Renvoie l'utilisateur inscrit
    } catch (e) {
      // Gère les erreurs d'inscription
      print('Erreur lors de l\'inscription: $e');
      return null; // Renvoie null en cas d'erreur
    }
  }

  // Fonction pour gérer la connexion d'un utilisateur existant
  Future<User?> signIn(String email, String password) async {
    try {
      // Connecte l'utilisateur avec l'email et le mot de passe fournis
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Utilisateur connecté: ${result.user}');
      return result.user; // Renvoie l'utilisateur connecté
    } catch (e) {
      // Gère les erreurs de connexion
      print('Erreur lors de la connexion: $e');
      return null; // Renvoie null en cas d'erreur
    }
  }

  // Fonction pour déconnecter l'utilisateur
  Future<void> signOut() async {
    await _auth.signOut();
    print('Utilisateur déconnecté'); // Message de confirmation de déconnexion
  }

  // Flux de données pour écouter les changements d'authentification
  Stream<User?> listenToAuthChanges() {
    return _auth.authStateChanges(); // Renvoie un flux d'état d'authentification
  }

  // Fonction pour ajouter un élément à l'inventaire
  Future<void> addInventoryItem(Map<String, dynamic> item) async {
    try {
      await FirebaseFirestore.instance.collection('inventory').add(item);
      print('Élément ajouté à l\'inventaire'); // Message de confirmation d'ajout
    } catch (e) {
      // Gère les erreurs lors de l'ajout d'un élément
      print('Erreur lors de l\'ajout de l\'élément: $e');
    }
  }

  // Flux de données pour obtenir des mises à jour sur les éléments d'inventaire
  Stream<QuerySnapshot<Map<String, dynamic>>> getInventoryStream() {
    return FirebaseFirestore.instance.collection('inventory').snapshots(); // Renvoie un flux de documents d'inventaire
  }
}
