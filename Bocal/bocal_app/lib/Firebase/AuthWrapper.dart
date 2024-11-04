import 'package:bocal_app/Firebase/role_based_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../AuthScreen/AuthScreen.dart';

// Widget de conteneur d'authentification qui détermine l'affichage basé sur l'état de l'utilisateur
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

// État du widget AuthWrapper
class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Écoute les changements d'état d'authentification
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Vérifie l'état de connexion du flux
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data; // Récupère l'utilisateur actuel

          // Vérifie si l'utilisateur est connecté
          if (user == null) {
            return AuthScreen(); // Affiche l'écran d'authentification si l'utilisateur n'est pas connecté
          } else if (user.emailVerified) {
            return RoleBasedContent(userId: user.uid); // Affiche le contenu basé sur le rôle si l'email est vérifié
          } else {
            return AuthScreen(); // Affiche l'écran d'authentification si l'email n'est pas vérifié
          }
        }
        // Affiche un indicateur de chargement pendant que l'état de connexion est déterminé
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
