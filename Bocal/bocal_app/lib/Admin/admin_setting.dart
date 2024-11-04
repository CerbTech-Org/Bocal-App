import 'package:bocal_app/AuthScreen/AuthScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Firebase/firebase_auth.dart';

class admin_setting extends StatefulWidget {
  const admin_setting({super.key});

  @override
  State<admin_setting> createState() => _admin_settingState();
}

class _admin_settingState extends State<admin_setting> {
  // permet de communiquer avec ma class "AuthService"
  final AuthService _authService = AuthService();
  // Controlleur des champs saisirs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initialisation de la vérification des données de l'admin ou users
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // récupère le user connecter actuel
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // récupération du nom et de l'email
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      // vérifie dans la collection 'admins' si ces données correspondes aux données précédentes
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
      if (!adminDoc.exists || !adminDoc.get('isAdmin')) {
        _showMessage(context, "Vous n'êtes pas autorisé à accéder à cette page.");
        // redirection vers la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
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
                constraints: BoxConstraints( // s'adapte en fonction de taille de l'app avec les dimensions qu'on lui donne
                    minHeight: MediaQuery.of(context).size.height -32
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsSection(
                      title: "Information de compte",
                      children: [
                        _buildTextField("Nom et prénoms", controller: _nameController),
                        _buildTextField("Email", keyboardType: TextInputType.emailAddress, controller: _emailController, enabled: false),
                        _buildTextField("Changer le mot de passe:", controller: _passwordController),
                        _buildTextField("Confirmer le nouveau mot de passe :", controller: _confirmPasswordController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () { // permet de clicker
                            _saveChanges(context);
                          },
                          child: Text("Enregistrer les modifications", style: GoogleFonts.lato(textStyle: TextStyle(color: Colors.black, fontSize: 16,)),),),
                      ],
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                          elevation: 5
                      ),
                      onPressed: () async {
                        try {
                          await _authService.signOut(); // déconnection de l'user ou l'admin
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil( // nétoie toutes les pages précédentes
                            MaterialPageRoute( // redirection vers la page de connexion
                              builder: (BuildContext context) {
                                return const AuthScreen();
                              },
                            ),
                                (_) => false,
                          );
                        } catch(e) {
                          _showMessage(context, 'Erreur lors de la déconnexion : $e');
                        }
                      },
                      child: const Text("Se déconnecter", style: TextStyle(
                          color: Colors.black
                      ),),
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

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2, // ombre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, // text à remplir
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.grey), // affiche une barre
            ...children, // ajout de plusieurs éléments
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {TextInputType? keyboardType, TextEditingController? controller, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField( // champs à remplir grâce au controlleur
        controller: controller,
        enabled: enabled, // permet soit de remplir soit de ne pas remplir
        keyboardType: keyboardType, // permet de spécifier le type de clavier à afficher lorsque l'utilisateur interagit avec le champ de saisie
        style: GoogleFonts.poppins(),
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    // stock les éléments entrez par l'admin
    String name = _nameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // vérifie si le nom est n'est pas vide et si le nom est différent de celui qui est affiché
        if (name.isNotEmpty && name != user.displayName) {
          // met à jour la donnée dans la collection admins en fonction de son "UID"
          await FirebaseFirestore.instance.collection('admins').doc(user.uid).update({
            'username': name,
          });
          // met à jour le nom
          await user.updateDisplayName(name);
        }
        // vérification si le mot de passe et confirmation de mot de passe n'est pas vide
        if (password.isNotEmpty && confirmPassword.isNotEmpty) {
          if (password.length < 6) {
            _showMessage(context, "Le mot de passe doit contenir au moins 6 caractères.");
            return;
          }
          // vérification si le mot de passe et confirmation de mot de passe se correspondent
          if (password != confirmPassword) {
            _showMessage(context,"Les mots de passe ne correspondent pas.");
            return;
          }
          // met à jour le password
          await user.updatePassword(password);
        }
        _showMessage(context,"Modifications enregistrées avec succès.");
      } else {
        _showMessage(context,"Aucun admin connecté.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = "Cette opération est sensible et nécessite une authentification récente. Reconnectez-vous avant de réessayer.";
          break;
        case 'email-already-in-use':
          errorMessage = "Cet email est déjà utilisé par un autre compte.";
          break;
        default:
          errorMessage = "Une erreur est survenue : ${e.message}";
      }
      _showMessage(context, errorMessage);
    } catch (e) {
      _showMessage(context, "Une erreur inattendue est survenue : $e");
    }
  }

}
