import 'package:bocal_app/Admin/adminPage.dart';
import 'package:bocal_app/Admin/admin_request_of_customer.dart';
import 'package:bocal_app/Admin/admin_setting.dart';
import 'package:flutter/material.dart';
import 'admin_inventory.dart';

class adminHome extends StatefulWidget {
  const adminHome({super.key});

  @override
  State<adminHome> createState() => _adminHomeState();
}

class _adminHomeState extends State<adminHome> {
  late PageController _pageController;
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    // initialisation du controlleur en fonction de la taille des pages
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    // libération du controlleur
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [ // liste ordonnée des pages pour la navigation
    AdminPage(),
    admin_request_of_customer(),
    AdminInventory(),
    admin_setting()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // affiche sur la même ligne le logo et l'Icons.person
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/aeig_blue.jpg',
                fit: BoxFit.contain,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Image not found');
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.person, color: Colors.blue),
            ),
          )
        ],
      ),
      body: Container(
        child: PageView( // permet de naviguer entre les différents les pages
          controller: _pageController,
          children: _pages.map((page) => page,
          ).toList(),
          onPageChanged: (index) {
            setState(() => _selectedIndex = index); // met à jour l'index pour la navigation
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // rend la barre de navigation fixe
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue, // rend un élément sélectionné de couleur blue
          unselectedItemColor: Colors.black, // rend un élément non-sélectionné de couleur noir
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
            );
          },
          items: [ // affiche les différentes pages sur la barre de navigation et ses icônes
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.mail_rounded), label: 'Demandes'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Inventaires'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Paramètres'),
          ],
        ),
      ),
    );
  }
}