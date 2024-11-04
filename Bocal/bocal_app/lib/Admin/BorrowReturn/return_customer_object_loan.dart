import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class return_customer_object_loan extends StatelessWidget {
  const return_customer_object_loan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Couleur de fond blanc
        backgroundColor: Colors.white,
      // Rembourage aux alentours du body
      body: Padding(
          padding: EdgeInsets.all(12.0),
        // Récupération des données en temps réel dans la base de donnée FirebaseFirestore
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collection('message_send_by_user')
            .where('status', isEqualTo: 'rendu')
            .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Stockage des données sous forme de liste ordonnée
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Aucun retour d'objet disponible",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                //   Permet de scroller
                } return SingleChildScrollView(
                  // Affichage des données sous formes de liste
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> request = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.receipt_long, size: 30, color: Colors.deepOrange),
                                  const SizedBox(width: 10),
                                  Text(
                                    request['object'] ?? 'Nom de l\'objet',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text("${request['username'] ?? 'inconnu'} vient de rendre ${request['object'] ?? 'Nom de l\'objet'}"),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Erreur: ${snapshot.error}');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
        ),
      )
    );
  }
}
