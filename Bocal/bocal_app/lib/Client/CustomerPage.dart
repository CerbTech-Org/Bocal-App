import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  int _currentLoansCount = 0;
  int _totalLoansCount = 0;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _fetchLoanCounts();
  }

  Future<void> _fetchLoanCounts() async {
    String? username = FirebaseAuth.instance.currentUser?.displayName;
    if (username != null) {
      _currentLoansCount = await _getLoansCount(username, 'accepté');
      _totalLoansCount = await _getLoansCount(username, 'rendu');
      setState(() {});
    }
  }

  Future<int> _getLoansCount(String username, String status) async {
    QuerySnapshot loansSnapshot = await FirebaseFirestore.instance
        .collection('message_send_by_user')
        .where('username', isEqualTo: username)
        .where('status', isEqualTo: status)
        .get();
    return loansSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<User?>(
        future: Future.value(FirebaseAuth.instance.currentUser),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            User user = snapshot.data!;
            String username = user.displayName ?? 'Utilisateur';
            return _buildUserInterface(username);
          } else {
            return const Center(child: Text('Utilisateur non trouvé.'));
          }
        },
      ),
    );
  }

  Widget _buildUserInterface(String username) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(username),
          const SizedBox(height: 30),
          _buildDashboardHeader(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 30),
          _buildCurrentLoansHeader(),
          const SizedBox(height: 20),
          _buildCurrentLoansList(username),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String username) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 40, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Bienvenue, $username!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Text(
      'Tableau de bord',
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildCurrentLoansHeader() {
    return Text(
      "Vos emprunts actuels",
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildCurrentLoansList(String username) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('message_send_by_user')
          .where('username', isEqualTo: username)
          .where('status', isEqualTo: 'accepté')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Aucun emprunt en cours!',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> request = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildLoanCard(request, snapshot.data!.docs[index].id);
          },
        );
      },
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> request, String docId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoanTitle(request['object']),
            const SizedBox(height: 10),
            _buildLoanDetail('Date d\'emprunt : ${request['borrowDate'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            _buildLoanDetail('Date de retour : ${request['returnDate'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            _buildReturnButton(docId),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTitle(String? objectName) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag, size: 30, color: Colors.deepOrange),
        const SizedBox(width: 10),
        Text(
          objectName ?? 'Nom de l\'objet',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildLoanDetail(String detail) {
    return Text(
      detail,
      style: const TextStyle(color: Colors.black54),
    );
  }

  Widget _buildReturnButton(String docId) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: () {
          _returnObjectBack(docId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Rendre maintenant',
          style: TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _returnObjectBack(String docId) async {
    try {
      DocumentSnapshot loanDoc = await FirebaseFirestore.instance
          .collection('message_send_by_user')
          .doc(docId)
          .get();
      if (loanDoc.exists) {
        Map<String, dynamic> loanData = loanDoc.data() as Map<String, dynamic>;
        String objectName = loanData['object'];
        int borrowedQuantity = loanData['quantity'];

        QuerySnapshot inventorySnapshot = await FirebaseFirestore.instance
            .collection('inventory')
            .where('name', isEqualTo: objectName)
            .get();

        if (inventorySnapshot.docs.isNotEmpty) {
          DocumentSnapshot inventoryDoc = inventorySnapshot.docs.first;
          int currentQuantity = inventoryDoc.get('remainingQuantity');
          int updatedQuantity = currentQuantity + borrowedQuantity;

          await inventoryDoc.reference.update({'remainingQuantity': updatedQuantity});
        }

        await FirebaseFirestore.instance
            .collection('message_send_by_user')
            .doc(docId)
            .update({'status': 'rendu'});

        _fetchLoanCounts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objet retourné avec succès.')),
        );
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors du retour de l\'objet: $e'
              )
          )
        );
      }
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard("Emprunts en cours", Icons.book, Colors.blue, _currentLoansCount),
        _buildStatCard("Emprunts totaux", Icons.library_books, Colors.orange, _totalLoansCount),
      ],
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color backgroundColor, int value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
