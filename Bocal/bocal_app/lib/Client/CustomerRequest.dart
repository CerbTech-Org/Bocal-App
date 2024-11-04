import 'package:bocal_app/Client/BorrowReturn/BorrowObject.dart';
import 'package:bocal_app/Client/BorrowReturn/ReturnObject.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerRequest extends StatefulWidget {
  const CustomerRequest({super.key});

  @override
  State<CustomerRequest> createState() => _CustomerRequestState();
}

class _CustomerRequestState extends State<CustomerRequest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controlleur du TabControlleer

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); //Initialisation du controlleur
  }

  @override
  void dispose() {
    _tabController.dispose(); //Libération du controlleur
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Couleur de fond de l'écran
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20), // Espacement en haut de l'écran
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Bordure circulaire
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // Couleur sombre du shadow
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),// Coins arrondis
                    color: Colors.blueAccent, // Couleur du sélecteur
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87, // Couleur du controlleur non sélectionné
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            "Emprunt d’objet",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            "Retour d’objet",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    Borrowobject(), // Redirection entre les pages
                    Returnobject(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
