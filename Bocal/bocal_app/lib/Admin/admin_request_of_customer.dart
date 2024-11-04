import 'package:bocal_app/Admin/BorrowReturn/acceptation_customer_object_loan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BorrowReturn/return_customer_object_loan.dart';

class admin_request_of_customer extends StatefulWidget {
  const admin_request_of_customer({super.key});

  @override
  State<admin_request_of_customer> createState() => _admin_request_of_customerState();
}

class _admin_request_of_customerState extends State<admin_request_of_customer> with SingleTickerProviderStateMixin {
  // Controlleur entre plusieurs switch
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // initialisation du controlleur pour prendre uniquement deux éléments
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Libération du controlleur
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea( //  assure que l'application s'affiche correctement sur différents types d'appareils (smartphones avec encoches, écrans incurvés, etc.), gère les marges de l'app
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueAccent,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [ // Déclaration des deux éléments
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
                child: TabBarView( // redirection respectivement des deux éléments
                  controller: _tabController,
                  children: const [
                    AcceptationCustomerObjectLoan(),
                    return_customer_object_loan(),
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