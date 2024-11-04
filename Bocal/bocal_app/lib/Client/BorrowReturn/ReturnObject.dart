import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Returnobject extends StatelessWidget {
  const Returnobject({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(12.0),
          // récupération des données en temps réel dans la collection "message_send_by_user" du status "rendu"
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('message_send_by_user')
                  .where('username', isEqualTo: FirebaseAuth.instance.currentUser!.displayName)
                  .where('status', isEqualTo: 'rendu')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // stock sous forme de liste ordonnée les données dans le doc de la collection "message_send_by_user" du status "rendu"
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
                  //  Il permet de scroller
                  } return SingleChildScrollView(
                    // affiche sous forme de liste
                    child: ListView.builder(
                        shrinkWrap: true, // Permet au ListView de prendre la taille nécessaire
                        physics: const NeverScrollableScrollPhysics(), // Désactive le défilement parce que "SingleChildScrollView" le gère déjà
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
                                      // affiche le nom de l'objet
                                      Text(
                                        request['object'] ?? 'Nom de l\'objet',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text("Vous venez de rendre ${request['object'] ?? 'Nom de l\'objet'}"),
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
