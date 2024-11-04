import 'package:flutter/material.dart';
import 'package:bocal_app/Client/CustomerNotifications.dart';
import 'package:bocal_app/Client/CustomerRequest.dart';
import 'package:bocal_app/Client/CustomerSettings.dart';
import 'package:bocal_app/Client/CustomerPage.dart';

class Studenthome extends StatefulWidget {
  const Studenthome({Key? key}) : super(key: key);

  @override
  State<Studenthome> createState() => _StudenthomeState();
}

class _StudenthomeState extends State<Studenthome> {
  late PageController _pageController;  // Contrôleur pour gérer les pages
  int _selectedIndex = 0;  // Index de la page sélectionnée

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);  // Initialise le contrôleur à la première page
  }

  @override
  void dispose() {
    _pageController.dispose();  // Libère les ressources utilisées par le contrôleur
    super.dispose();
  }

  // Liste des pages à afficher dans l'application
  final List<Widget> _pages = [
    CustomerPage(),  // Page d'accueil
    CustomerRequest(),  // Page des demandes
    Customernotifications(),  // Page des notifications
    CustomerSettings()  // Page des paramètres
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Barre d'en-tête de l'application
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),  // Légère ombre sous le logo
                  ),
                ],
              ),
              // Affichage du logo avec gestion des erreurs
              child: Image.asset(
                'assets/images/aeig_blue.jpg',
                fit: BoxFit.contain,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Image not found');  // Message si l'image n'est pas trouvée
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,  // Couleur de fond de la barre d'en-tête
        elevation: 0,  // Supprime l'ombre de l'AppBar
        actions: [
          // Icône de profil dans la barre d'en-tête
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},  // Action à définir
              icon: Icon(Icons.person, color: Colors.blue),  // Icône de profil
            ),
          )
        ],
      ),
      // Corps de la page avec un PageView pour la navigation
      body: PageView(
        controller: _pageController,  // Utilise le contrôleur pour changer de page
        children: _pages.map((page) => page).toList(),  // Affiche chaque page
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);  // Met à jour l'index de la page sélectionnée
        },
      ),
      // Barre de navigation en bas de l'écran
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),  // Ombre sous la barre de navigation
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,  // Navigation fixe
          backgroundColor: Colors.white,  // Couleur de fond de la barre
          selectedItemColor: Colors.blue,  // Couleur de l'élément sélectionné
          unselectedItemColor: Colors.black,  // Couleur des éléments non sélectionnés
          currentIndex: _selectedIndex,  // Indique l'élément actuellement sélectionné
          onTap: (index) {
            setState(() => _selectedIndex = index);  // Change l'index lorsqu'on appuie sur un élément
            _pageController.animateToPage(  // Anime le changement de page
              index,
              duration: Duration(milliseconds: 300),  // Durée de l'animation
              curve: Curves.easeOutQuad,  // Courbe d'animation
            );
          },
          // Définit les éléments de la barre de navigation
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.mail_rounded), label: 'Demandes'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Paramètres'),
          ],
        ),
      ),
    );
  }
}
