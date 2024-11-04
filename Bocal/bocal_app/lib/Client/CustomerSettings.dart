import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AuthScreen/AuthScreen.dart';
import '../Firebase/firebase_auth.dart';

// Widget de paramètres client
class CustomerSettings extends StatefulWidget {
  const CustomerSettings({super.key});

  @override
  State<CustomerSettings> createState() => _CustomerSettingsState();
}

// État du widget CustomerSettings
class _CustomerSettingsState extends State<CustomerSettings> {
  // Contrôleurs de texte pour les champs de saisie
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // AuthService pour gérer l'authentification
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Récupération des informations de l'utilisateur courant
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
            builder: (BuildContext context) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 32
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section des informations de compte
                      _buildSettingsSection(
                        title: "Information de compte",
                        children: [
                          _buildTextField("Nom et prénoms", controller: _nameController, enabled: false),
                          _buildTextField("Email", controller: _emailController, keyboardType: TextInputType.emailAddress, enabled: false),
                          _buildTextField("Nouveau mot de passe:", controller: _passwordController, isPassword: true),
                          _buildTextField("Confirmer le nouveau mot de passe :", controller: _confirmPasswordController, isPassword: true),
                          const SizedBox(height: 20,),
                          // Bouton pour changer le mot de passe
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              _changePassword(context);
                            },
                            child: Text(
                              "Changer le mot de passe",
                              style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Section de support
                      _buildSupportSection(),
                      const SizedBox(height: 50),
                      // Bouton de déconnexion
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 16),
                            elevation: 5
                        ),
                        onPressed: () async {
                          try {
                            await _authService.signOut(); // Déconnexion
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const AuthScreen(); // Retour à l'écran d'authentification
                                },
                              ),
                                  (_) => false,
                            );
                          } catch(e) {
                            _showMessage(context, 'Erreur lors de la déconnexion : $e');
                          }
                        },
                        child: const Text(
                          "Se déconnecter",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }

  // Méthode pour construire une section de paramètres
  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.grey),
            ...children, // Ajoute les enfants à la section
          ],
        ),
      ),
    );
  }

  // Méthode pour construire un champ de texte
  Widget _buildTextField(String label, {TextInputType? keyboardType, TextEditingController? controller, bool enabled = true, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(),
        enabled: enabled,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire la section de support
  Widget _buildSupportSection() {
    return GestureDetector(
      onTap: () => _launchEmail("marlinibukun@gmail.com", context), // Lancer l'email au tap
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Support",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  // Méthode pour lancer l'application email
  Future<void> _launchEmail(String email, BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        final Uri genericIntent = Uri(
          scheme: 'intent',
          host: '',
          path: '/',
          queryParameters: {
            'action': 'android.intent.action.SENDTO',
            'data': emailUri.toString(),
          },
        );
        if (await canLaunchUrl(genericIntent)) {
          await launchUrl(genericIntent);
        } else {
          throw 'Impossible d\'ouvrir l\'application email';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  // Méthode pour afficher un message dans un SnackBar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Méthode pour changer le mot de passe de l'utilisateur
  Future<void> _changePassword(BuildContext context) async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (password.isEmpty || confirmPassword.isEmpty) {
          _showMessage(context, "Veuillez remplir tous les champs de mot de passe.");
          return;
        }

        if (password.length < 6) {
          _showMessage(context, "Le mot de passe doit contenir au moins 6 caractères.");
          return;
        }

        if (password != confirmPassword) {
          _showMessage(context, "Les mots de passe ne correspondent pas.");
          return;
        }

        await user.updatePassword(password); // Mise à jour du mot de passe
        _showMessage(context, "Mot de passe modifié avec succès.");
        _passwordController.clear(); // Effacement des champs
        _confirmPasswordController.clear();
      } else {
        _showMessage(context, "Aucun utilisateur connecté.");
      }
    } catch (e) {
      _showMessage(context, "Une erreur est survenue lors du changement de mot de passe.");
    }
  }
}
