import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AcceptationCustomerObjectLoan extends StatefulWidget {
  const AcceptationCustomerObjectLoan({super.key});

  @override
  State<AcceptationCustomerObjectLoan> createState() => _AcceptationCustomerObjectLoanState();
}

class _AcceptationCustomerObjectLoanState extends State<AcceptationCustomerObjectLoan> {
  Map<String, bool> buttonVisibility = {};
  String? adminName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('message_send_by_user')
              .where('status', isEqualTo: 'en attente')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<DocumentSnapshot> docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text("Aucune demande en attente."));
            }
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> request = docs[index].data() as Map<String, dynamic>;
                if (!buttonVisibility.containsKey(docs[index].id)) {
                  buttonVisibility[docs[index].id] = true;
                }
                bool areButtonsVisible = buttonVisibility[docs[index].id] ?? true;
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${request['username']} souhaite emprunter ${request['object']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Quantité: ${request['quantity']}'),
                        Text('Date d\'emprunt: ${request['borrowDate']}'),
                        Text('Date de retour: ${request['returnDate']}'),
                        const SizedBox(height: 15),
                        if (areButtonsVisible)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _handleAcceptRequest(docs[index].id, request);
                                },
                                icon: const Icon(Icons.check, color: Colors.black),
                                label: const Text('Accepter', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _handleRejectRequest(docs[index].id, request);
                                },
                                icon: const Icon(Icons.close, color: Colors.black),
                                label: const Text('Refuser', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleAcceptRequest(String requestId, Map<String, dynamic> request) async {
    try {
      var inventoryDoc = await FirebaseFirestore.instance
          .collection('inventory')
          .where('name', isEqualTo: request['object'])
          .get();

      if (inventoryDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objet non trouvé dans l\'inventaire.')),
        );
        return;
      }

      int currentRemainingQuantity = inventoryDoc.docs.first.get('remainingQuantity');
      num newRemainingQuantity = currentRemainingQuantity - request['quantity'];

      await inventoryDoc.docs.first.reference.update({
        'remainingQuantity': newRemainingQuantity,
      });

      await FirebaseFirestore.instance.collection('message_send_by_user').doc(requestId).update({
        'status': 'accepté',
        'username': request['username'],
        'read': false,
        'message': 'Votre demande d’emprunt de l’objet ${request['object']} a été acceptée.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande acceptée et notification envoyée.')),
      );

      setState(() {
        buttonVisibility[requestId] = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'acceptation de la demande.')),
      );
    }
  }

  Future<void> _handleRejectRequest(String requestId, Map<String, dynamic> request) async {
    try {
      await FirebaseFirestore.instance.collection('message_send_by_user').doc(requestId).update({
        'status': 'refusé',
        'username': request['username'],
        'read': false,
        'message': 'Votre demande d’emprunt de l’objet ${request['object']} a été refusée.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande refusée et notification envoyée.')),
      );

      setState(() {
        buttonVisibility[requestId] = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du refus de la demande.')),
      );
    }
  }
}