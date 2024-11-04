import 'package:firebase_core/firebase_core.dart';  // Importe Firebase Core pour initialiser Firebase
import 'package:flutter/material.dart';  // Importe les widgets de Flutter
import 'SplashScreen/home.dart';  // Importation de l'écran d'accueil ou SplashScreen

// Fonction principale exécutée au démarrage de l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Assure que les widgets Flutter sont initialisés correctement avant d'utiliser Firebase
  await Firebase.initializeApp();  // Initialise Firebase pour l'application (nécessaire pour utiliser les services Firebase)
  runApp(const MyApp());  // Lance l'application Flutter en utilisant la classe MyApp
}

// Classe principale de l'application, ici MyApp, qui est un StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Constructeur de MyApp

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Désactive la bannière de mode debug dans le coin supérieur droit
      home: const SplashScreen(),  // Définit la page d'accueil de l'application sur l'écran de démarrage (SplashScreen)
    );
  }
}
