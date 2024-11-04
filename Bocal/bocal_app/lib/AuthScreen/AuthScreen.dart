import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  // Importe Google Fonts pour personnaliser les polices
import 'connexion.dart';  // Importe l'écran de connexion
import 'inscription.dart';  // Importe l'écran d'inscription

// Déclaration d'un StatefulWidget pour l'écran d'authentification
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// État de l'écran d'authentification avec un mixin pour la gestion des animations avec un TabController
class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;  // Contrôleur des onglets

  @override
  void initState() {
    super.initState();
    // Initialise le TabController avec deux onglets et synchronisation avec l'écran actuel (vsync)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();  // Libère les ressources du TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Définit le fond de l'écran à blanc
      body: SafeArea(
        child: Column(
          children: [
            // Ajout du logo avec gestion des erreurs en cas d'image manquante
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Image.asset(
                'assets/images/aeig_blue.jpg',  // Chemin du logo
                width: 180,  // Largeur du logo
                height: 120,  // Hauteur du logo
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, size: 80, color: Colors.red);  // Icône si image introuvable
                },
              ),
            ),
            // Contenu principal avec onglets
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,  // Fond blanc
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),  // Arrondi en haut à gauche
                    topRight: Radius.circular(30),  // Arrondi en haut à droite
                  ),
                  boxShadow: [
                    // Ombre pour l'effet d'élévation du conteneur
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),  // Décalage de l'ombre
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ajoute les onglets Connexion et Inscription
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TabBar(
                        controller: _tabController,  // Contrôleur des onglets
                        indicator: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          color: Colors.blue,  // Couleur de l'onglet sélectionné
                        ),
                        labelColor: Colors.white,  // Couleur du texte des onglets sélectionnés
                        unselectedLabelColor: Colors.blue,  // Couleur du texte des onglets non sélectionnés
                        tabs: [
                          _buildTab("Connexion"),  // Onglet Connexion
                          _buildTab("Inscription"),  // Onglet Inscription
                        ],
                      ),
                    ),
                    // Contenu des onglets (vue Connexion et vue Inscription)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,  // Contrôleur des vues des onglets
                        children: const [
                          Connexion(),  // Page de connexion
                          Inscription(),  // Page d'inscription
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour créer chaque onglet avec du texte personnalisé
  Widget _buildTab(String text) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),  // Padding vertical à l'intérieur de l'onglet
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),  // Bordures arrondies pour l'onglet
          border: Border.all(color: Colors.blue, width: 1),  // Bordure bleue autour de l'onglet
        ),
        child: Align(
          alignment: Alignment.center,  // Aligne le texte au centre
          child: Text(
            text,  // Texte de l'onglet (Connexion ou Inscription)
            style: GoogleFonts.poppins(fontSize: 19),  // Utilisation de la police Poppins
            overflow: TextOverflow.ellipsis,  // Gère le débordement du texte
          ),
        ),
      ),
    );
  }
}
