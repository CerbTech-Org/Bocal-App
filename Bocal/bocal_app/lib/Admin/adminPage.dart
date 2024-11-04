import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _totalItemsBorrowed = 0;
  String _mostBorrowedObject = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Récupère les données de la collection 'message_send_by_user'
    // pour le statut "accepté".
    QuerySnapshot loansAcceptedSnapshot = await FirebaseFirestore.instance
        .collection('message_send_by_user')
        .where('status', isEqualTo: 'accepté')
        .get();

    // Récupère les données de la collection 'message_send_by_user'
    // pour le statut "rendu".
    QuerySnapshot loansReturnedSnapshot = await FirebaseFirestore.instance
        .collection('message_send_by_user')
        .where('status', isEqualTo: 'rendu')
        .get();

    // Regroupe les documents retournés par objet.
    var objectCounts = groupBy(loansReturnedSnapshot.docs, (DocumentSnapshot doc) => doc.get('object'));

    setState(() {
      // Met à jour le nombre total d'objets empruntés avec le nombre de
      // documents ayant le statut "accepté".
      _totalItemsBorrowed = loansAcceptedSnapshot.docs.length;

      // Vérifie s'il y a des objets retournés et détermine l'objet le plus emprunté.
      if (objectCounts.entries.isNotEmpty) {
        // Trouve l'entrée avec le plus grand nombre d'objets empruntés.
        var mostBorrowedEntry = objectCounts.entries.reduce((a, b) => a.value.length > b.value.length ? a : b);
        _mostBorrowedObject = mostBorrowedEntry.key ?? 'Aucun objet emprunté';
      } else {
        // Aucune entrée retournée.
        _mostBorrowedObject = 'Aucun objet emprunté';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          User user = snapshot.data!;
          String username = user.displayName ?? 'Utilisateur';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(username),
                const SizedBox(height: 20),
                _buildDashboardTitle(),
                const SizedBox(height: 30),
                _buildStatGrid(),
                const SizedBox(height: 30),
                _buildHistoryTitle(),
                const SizedBox(height: 20),
                _buildLoanHistory(),
              ],
            ),
          );
        } else {
          return const Text('Utilisateur non trouvé.');
        }
      },
    );
  }

  Widget _buildWelcomeCard(String username) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 32, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text( // affiche le nom de l'user
              'Bienvenue $username',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TABLEAU DE BORD',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(2, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      // Définit le nombre de colonnes en fonction de la largeur de l'écran.
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,

      // Espacement horizontal entre les éléments de la grille.
      crossAxisSpacing: 10,

      // Espacement vertical entre les éléments de la grille.
      mainAxisSpacing: 10,

      // Permet à la grille de s'adapter à la taille de son contenu.
      shrinkWrap: true,

      // Empêche le défilement de la grille.
      physics: const NeverScrollableScrollPhysics(),

      // Liste des enfants (widgets) à afficher dans la grille.
      children: [
        // Carte pour afficher le nombre d'emprunts en cours.
        _buildStatCard("Emprunts en cours", Icons.book, Colors.blue, _totalItemsBorrowed),

        // Carte pour afficher l'objet le plus emprunté.
        _buildStatCard("Le plus emprunté", Icons.library_books, Colors.orange, _mostBorrowedObject),
      ],
    );
  }

  Widget _buildHistoryTitle() {
    return Text(
      "Historique",
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('message_send_by_user')
          .where('status', isEqualTo: 'accepté')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Aucun historique d'emprunt."));
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              Map<String, dynamic> request = docs[index].data() as Map<String, dynamic>;
              return _buildLoanCard(request);
            },
          );
        } else if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> request) {
    String username = request['username'] ?? 'Inconnu';
    String object = request['object'] ?? 'Objet non spécifié';
    String borrowDate = request['borrowDate'] ?? 'Date inconnue';
    String returnDate = request['returnDate'] ?? 'Date de retour inconnue';

    IconData statusIcon;
    Color statusColor;
    try {
      // Crée une instance de DateFormat pour le format de date spécifié "dd/MM/yyyy".
      DateFormat format = DateFormat("dd/MM/yyyy");

      // Parse la chaîne de date 'returnDate' en un objet DateTime.
      DateTime returnDateTime = format.parse(returnDate);

      // Vérifie si la date de retour est avant la date et l'heure actuelles.
      if (returnDateTime.isBefore(DateTime.now())) {
        // Si la date de retour est passée, attribue une icône d'avertissement et une couleur rouge.
        statusIcon = Icons.warning_amber_rounded; // Icône indiquant un avertissement.
        statusColor = Colors.redAccent; // Couleur rouge pour signaler une alerte.
      } else {
        // Si la date de retour est future, attribue une icône de confirmation et une couleur verte.
        statusIcon = Icons.check_circle; // Icône indiquant que la date est valide.
        statusColor = Colors.green; // Couleur verte pour indiquer que tout est en ordre.
      }
    } catch (e) {
      // En cas d'erreur lors du parsing de la date, attribue une icône d'erreur et une couleur grise.
      statusIcon = Icons.error; // Icône indiquant une erreur.
      statusColor = Colors.grey; // Couleur grise pour signaler une erreur.
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(statusIcon, color: statusColor, size: 35),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ // affichage des données envoyées par le user
                  Text("Nom: $username", style: _textStyle()),
                  Text("Objet: $object", style: _textStyle()),
                  Text("Date d'emprunt: $borrowDate", style: _textStyle()),
                  Text("Date de retour: $returnDate", style: _textStyle()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return GoogleFonts.roboto(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color backgroundColor, dynamic value) {
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Expanded( // affiche la value de l'emprunt
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
