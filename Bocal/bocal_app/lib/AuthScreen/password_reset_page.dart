import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bocal_app/AuthScreen/AuthScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Page de réinitialisation de mot de passe pour les utilisateurs ayant une adresse Epitech
class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  // Contrôleur pour le champ d'email
  final TextEditingController _emailController = TextEditingController();
  // Indicateur pour l'état de chargement lors de l'envoi de l'email
  bool _isLoading = false;
  // Instance de FirebaseAuth pour l'envoi de l'email de réinitialisation
  final _auth = FirebaseAuth.instance;

  /// Vérifie si l'email est valide et correspond au domaine 'epitech.eu'
  bool _isEmailValid(String email) {
    final regex = RegExp(r"^[a-z.-]+@epitech\.eu$");
    return regex.hasMatch(email);
  }

  /// Fonction pour envoyer un email de réinitialisation de mot de passe
  void _resetPassword() async {
    // Vérification si le champ est vide ou si l'email n'est pas valide
    if (_emailController.text.isEmpty || !_isEmailValid(_emailController.text)) {
      // Affiche un message d'erreur si l'email est invalide
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un email Epitech valide')),
      );
      return;
    }

    // Active l'état de chargement
    setState(() {
      _isLoading = true;
    });

    try {
      // Envoie l'email de réinitialisation via Firebase
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      // Affiche une confirmation si l'email a été envoyé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email de réinitialisation envoyé")),
      );
    } catch (e) {
      // Capture et affiche l'erreur en cas d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      // Désactive l'état de chargement
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arrière-plan avec un dégradé de bleu
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.08,
                        vertical: constraints.maxHeight * 0.05,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo ou icône de l'application
                          Flexible(
                            flex: 2,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(constraints.maxHeight * 0.02),
                                child: Image.asset(
                                  'assets/images/epitech.png',
                                  height: constraints.maxHeight * 0.1,
                                  color: Colors.white,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.lock_reset, size: constraints.maxHeight * 0.1, color: Colors.white);
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Titre de la page
                          Flexible(
                            flex: 1,
                            child: Text(
                              "Mot de passe oublié ?",
                              style: GoogleFonts.poppins(
                                fontSize: constraints.maxHeight * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          // Description de la procédure de réinitialisation
                          Flexible(
                            flex: 1,
                            child: Text(
                              "Pas de soucis ! Entrez votre email Epitech et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
                              style: GoogleFonts.poppins(
                                fontSize: constraints.maxHeight * 0.018,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          // Formulaire de saisie d'email
                          Flexible(
                            flex: 3,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(constraints.maxHeight * 0.02),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Champ de saisie pour l'email
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email Epitech',
                                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.blue.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.blue, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                      ),
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    SizedBox(height: constraints.maxHeight * 0.02),
                                    // Bouton de réinitialisation de mot de passe
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _resetPassword,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.blue,
                                        padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.015),
                                        textStyle: GoogleFonts.poppins(
                                          fontSize: constraints.maxHeight * 0.018,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                        width: constraints.maxHeight * 0.025,
                                        height: constraints.maxHeight * 0.025,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                          : Padding(
                                        padding: EdgeInsets.all(constraints.maxHeight * 0.01),
                                        child: Text(
                                          "Réinitialiser le mot de passe",
                                          style: GoogleFonts.poppins(
                                            fontSize: constraints.maxHeight * 0.018,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          // Bouton pour revenir à l'écran de connexion
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                            },
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            label: Text(
                              "Retour à la connexion",
                              style: GoogleFonts.poppins(
                                fontSize: constraints.maxHeight * 0.018,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
