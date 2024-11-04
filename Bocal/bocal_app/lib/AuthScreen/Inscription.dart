import 'package:bocal_app/AuthScreen/AuthScreen.dart'; // Importation de l'écran de connexion.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importation de Firestore pour interagir avec la base de données.
import 'package:flutter/material.dart'; // Importation de Flutter pour construire l'interface utilisateur.
import 'package:firebase_auth/firebase_auth.dart'; // Importation de Firebase Auth pour l'authentification des utilisateurs.
import 'package:bocal_app/Firebase/firebase_auth.dart'; // Importation du service d'authentification personnalisé.

/// Classe représentant l'écran d'inscription.
class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final TextEditingController _emailController = TextEditingController(); // Contrôleur pour le champ d'email.
  final TextEditingController _passwordController = TextEditingController(); // Contrôleur pour le champ de mot de passe.
  final TextEditingController _usernameController = TextEditingController(); // Contrôleur pour le champ de nom d'utilisateur.
  bool _passwordVisible = false; // Indicateur de visibilité du mot de passe.
  bool _isLoading = false; // Indicateur de chargement lors de l'inscription.

  final AuthService _authService = AuthService(); // Instance du service d'authentification.

  @override
  void dispose() {
    // Dispose des contrôleurs lors de la destruction de l'écran.
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40), // Ajoute des marges autour du contenu.
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 32 // Contrainte de hauteur minimale.
          ),
          child: Column(
            children: [
              const Text(
                "Bienvenue !", // Titre de bienvenue.
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Remplissez ce formulaire pour créer votre compte", // Sous-titre d'instruction.
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              // Champ pour le nom d'utilisateur
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur', // Étiquette du champ.
                  prefixIcon: Icon(Icons.person, color: Colors.blue), // Icône à gauche.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Coins arrondis.
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2), // Bordure bleue au focus.
                  ),
                ),
                style: const TextStyle(color: Colors.black87), // Couleur du texte.
              ),
              const SizedBox(height: 20),
              // Champ pour l'email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email', // Étiquette du champ.
                  prefixIcon: Icon(Icons.email, color: Colors.blue), // Icône à gauche.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Coins arrondis.
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2), // Bordure bleue au focus.
                  ),
                ),
                style: const TextStyle(color: Colors.black87), // Couleur du texte.
              ),
              const SizedBox(height: 20),
              // Champ pour le mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible, // Masque le mot de passe selon l'état de visibilité.
                decoration: InputDecoration(
                  labelText: 'Mot de Passe', // Étiquette du champ.
                  prefixIcon: Icon(Icons.lock, color: Colors.blue), // Icône à gauche.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Coins arrondis.
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2), // Bordure bleue au focus.
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off, // Icône de visibilité.
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible; // Change l'état de visibilité du mot de passe.
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.black87), // Couleur du texte.
              ),
              const SizedBox(height: 30),
              // Bouton d'inscription
              GestureDetector(
                onTap: _signup, // Appelle la méthode _signup à l'appui.
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue, // Couleur de fond du bouton.
                    borderRadius: BorderRadius.circular(10), // Coins arrondis.
                  ),
                  child: Center(
                    child: const Text(
                      "S’inscrire", // Texte du bouton.
                      style: TextStyle(fontSize: 18, fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.red), // Affiche un indicateur de chargement si _isLoading est vrai.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child:
                    Text(
                      "Vous avez déjà un compte ?", // Texte d'invitation à se connecter.
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Redirige vers l'écran de connexion.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      );
                    },
                    child: const Text(
                      "Connectez-vous", // Texte du lien de connexion.
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Image.asset(
                    'assets/images/epitech.png', // Logo affiché au bas de l'écran.
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      // Affiche une icône d'erreur si l'image ne peut pas être chargée.
                      return const Icon(Icons.error_outline, size: 80, color: Colors.red);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Méthode d'inscription.
  void _signup() async {
    String email = _emailController.text.trim(); // Récupère l'email.
    String password = _passwordController.text.trim(); // Récupère le mot de passe.
    String username = _usernameController.text.trim(); // Récupère le nom d'utilisateur.

    // Vérifie si les champs sont remplis.
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _showMessage("Veuillez entrer un email, un mot de passe et un nom d'utilisateur valides.");
      return;
    }

    // Vérifie la validité de l'email.
    if (!_isEmailValid(email)) {
      _showMessage("Veuillez utiliser un email Epitech valide.");
      return;
    }

    // Vérifie la longueur du mot de passe.
    if (password.length < 6) {
      _showMessage("Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }

    setState(() {
      _isLoading = true; // Active le chargement lors de l'inscription.
    });

    try {
      // Essaye de créer un nouvel utilisateur.
      User? user = await _authService.signUp(email, password);
      if (user != null) {
        // Met à jour le nom d'affichage de l'utilisateur.
        await user.updateDisplayName(username);
        // Envoie un email de vérification.
        await user.sendEmailVerification();
        _showMessage("Un e-mail de vérification a été envoyé. Veuillez vérifier votre boîte de réception.");

        // Enregistre l'utilisateur dans Firestore.
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'isEmailVerified': false
        });
        user = FirebaseAuth.instance.currentUser; // Récupère l'utilisateur courant.
        // Redirige vers l'écran de connexion.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message.toString()); // Affiche les erreurs d'authentification.
    } finally {
      setState(() {
        _isLoading = false; // Désactive le chargement après l'inscription.
      });
    }
  }

  /// Affiche un message d'erreur.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)), // Affiche un Snackbar avec le message.
    );
  }

  /// Vérifie si l'email est valide.
  bool _isEmailValid(String email) {
    // Vérifie si l'email se termine par '@epitech.eu'.
    return email.endsWith('@epitech.eu');
  }
}
