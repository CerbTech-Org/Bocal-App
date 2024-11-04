import 'package:bocal_app/Admin/adminHome.dart';
import 'package:bocal_app/AuthScreen/AuthScreen.dart';
import 'package:bocal_app/AuthScreen/password_reset_page.dart';
import 'package:bocal_app/Client/CustomerHome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController _emailController = TextEditingController(); // Champs de saisir d'email
  final TextEditingController _passwordController = TextEditingController(); // Champs de saisir du password
  bool _passwordVisible = false; // Visibilité du mot de passe
  bool _isLoading = false; // Visibilité du cercle de chargement
  final bool _isAdmin = true; //

  @override
  void dispose() {
    _emailController.dispose(); // Libération du Champs de saisir d'email
    _passwordController.dispose(); // Libération du Champs de saisir du password
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 32,
          ),
          child: Column(
            children: [
              const Text(
                "De Retour ?",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Entrez vos informations de connexion",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Mot de Passe',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordResetPage()),
                    );
                  },
                  child: const Text(
                    "Mot de Passe oublié?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _signIn,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.red),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Pas de compte?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      );
                    },
                    child: const Text(
                      "Inscrivez-vous",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Image.asset(
                  'assets/images/epitech.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error_outline, size: 80, color: Colors.red);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Fonction d'affichage d'un message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  // Validation de l'addresse email
  bool checkEmail(String email) {
    final regex = RegExp(r"^[a-z.-]+@epitech\.eu$");
    return regex.hasMatch(email);
  }

  void _signIn() async {
    // Récupère l'email et le mot de passe entrés par l'utilisateur
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Définit la langue de l'authentification à français
    FirebaseAuth.instance.setLanguageCode("fr");

    // Vérifie si l'email et le mot de passe sont renseignés
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Veuillez entrer un email et un mot de passe valide.");
      return; // Sort de la méthode si les champs sont vides
    }

    // Affiche un indicateur de chargement
    setState(() {
      _isLoading = true;
    });

    try {
      // Tente de se connecter avec l'email et le mot de passe fournis
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user; // Récupère l'utilisateur connecté

      // Vérifie si l'utilisateur est un administrateur dans Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        // Si l'utilisateur est un admin, met à jour le token FCM dans Firestore
        String? adminFcmToken = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).update({
          'fcmToken': adminFcmToken,
          'email': email,
          'isAdmin': _isAdmin
        });
        // Redirige vers la page d'accueil de l'admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const adminHome()),
        );
      } else {
        // Si l'utilisateur est un client et a vérifié son email
        if (user != null && user.emailVerified) {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).update({
            'fcmToken': fcmToken,
            'isEmailVerified': true
          });
          // Redirige vers la page d'accueil du client
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Studenthome()),
          );
        } else {
          // Si l'email n'est pas vérifié, envoie un email de vérification
          _showMessage("Veuillez vérifier votre e-mail avant de vous connecter.");
          await user?.sendEmailVerification();
          _showMessage("Un e-mail de vérification a été renvoyé. Veuillez vérifier votre boîte de réception.");
        }
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs d'authentification Firebase
      setState(() {
        _isLoading = false; // Arrête l'indicateur de chargement
      });
      switch (e.code) {
        case 'user-not-found':
          _showMessage("Utilisateur non trouvé. Veuillez vérifier votre email.");
          break;
        case 'wrong-password':
          _showMessage("Mot de passe incorrect. Veuillez réessayer.");
          break;
        case 'too-many-requests':
          _showMessage("Trop de tentatives. Veuillez réessayer plus tard.");
          break;
        case 'network-request-failed':
          _showMessage("Erreur réseau. Veuillez vérifier votre connexion.");
          break;
        case 'invalid-email':
          _showMessage("Format de l'email incorrect.");
          break;
        default:
          _showMessage("Une erreur est survenue. Veuillez réessayer.");
      }
    } catch (e) {
      // Gestion d'autres erreurs potentielles
      setState(() {
        _isLoading = false; // Arrête l'indicateur de chargement
      });
      _showMessage("Une erreur est survenue. Veuillez réessayer.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

}