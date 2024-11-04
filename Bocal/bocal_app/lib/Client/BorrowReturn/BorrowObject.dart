import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Borrowobject extends StatefulWidget {
  const Borrowobject({super.key});

  @override
  State<Borrowobject> createState() => _BorrowobjectState();
}

class _BorrowobjectState extends State<Borrowobject> {
  bool _isBorrowFormVisible = false;
  DateTime? _selectedBorrowDate;
  DateTime? _selectedReturnDate;
  int _quantity = 1;
  String? _selectedObjectName;
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allItems = [];

  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadInventoryItems();
    _searchController.addListener(_filterItems);
  }

  Future<void> _loadInventoryItems() async {
    _allItems = await _getInventoryItems();
    if(mounted) {
      setState(() {
        _filteredItems = _allItems;
      });
    }
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return item['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<List<Map<String, dynamic>>> _getInventoryItems() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('inventory').get();
    return snapshot.docs.map((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      if (data['image'] != null) {
        data['image'] = (data['image'] as Blob).bytes;
      }
      data['isAvailable'] = data['isAvailable'] == 1 || data['isAvailable'] == true;
      return data;
    }).toList();
  }

  Future<void> _requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('L\'autorisation de notification a été accordée.');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('L\'autorisation de notification provisoire a été accordée.');
    } else {
      print('L\'autorisation de notification a été refusée.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _isBorrowFormVisible = false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un objet',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getInventoryItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (_filteredItems.isEmpty) {
                        return Center(child: Text('Aucun élément trouvé'));
                      }
                      return ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> item = _filteredItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: _buildItemCard(item),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              if (_isBorrowFormVisible)
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildBorrowForm(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: item['image'] != null
                      ? Image.memory(item['image'], width: 70, height: 70, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Quantité initiale: ${item['initialQuantity']}'),
                      Text('Quantité restante: ${item['remainingQuantity']}'),
                      RichText(
                        text: TextSpan(
                          text: 'Statut: ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: item['isAvailable'] == true ? 'Disponible' : 'Indisponible',
                              style: TextStyle(
                                color: item['isAvailable'] == true ? Colors.green : Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item['isAvailable'] == true)
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isBorrowFormVisible = true;
                      _selectedObjectName = item['name'];
                    });
                  },
                  child: const Text('Emprunter'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Emprunter ${_selectedObjectName ?? ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDateField('Date d\'emprunt', _selectedBorrowDate, (date) {
              setState(() {
                _selectedBorrowDate = date;
              });
            }),
            const SizedBox(height: 16),
            _buildDateField('Date de retour', _selectedReturnDate, (date) {
              setState(() {
                _selectedReturnDate = date;
              });
            }),
            const SizedBox(height: 16),
          Row(
            children: [
              const Text('Quantité:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<int>(
                  value: _quantity,
                  onChanged: (int? newValue) {
                    setState(() {
                      _quantity = newValue!;
                    });
                  },
                  underline: Container(),
                  isExpanded: false,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  items: List.generate(100, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              onPressed: () async {
                _sendBorrowRequest();
              },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Envoyer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendBorrowRequest() async {
    if (_selectedBorrowDate == null || _selectedReturnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez remplir tous les champs',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                )
            ),
          )
      );
    } else if (_selectedObjectName != null) {
      setState(() {
        _isLoading = true;
      });

      if (_selectedBorrowDate != null && _selectedReturnDate != null) {
        if (_selectedReturnDate!.isBefore(_selectedBorrowDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'La date de retour doit être supérieure à la date d\'emprunt.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      try {
        String? username = FirebaseAuth.instance.currentUser?.displayName;
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        String? adminFcmToken = await _getAdminFcmToken();

        if (adminFcmToken != null) {
          await FirebaseFirestore.instance.collection('message_send_by_user').add({
            'username': username ?? 'Utilisateur inconnu',
            'object': _selectedObjectName!,
            'quantity': _quantity,
            'borrowDate': _formatDate( _selectedBorrowDate!),
            'returnDate': _formatDate(_selectedReturnDate!),
            'status': 'en attente',
            'userId': uid,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demande d\'emprunt envoyée avec succès'))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible de contacter l\'administrateur'))
          );
        }
      } catch (e) {
        print('Erreur lors de l\'envoi de la demande d\'emprunt: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.'))
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun objet sélectionné'))
      );
    }
  }

  Future<String?> _getAdminFcmToken() async {
    try {
      QuerySnapshot adminQuery = await FirebaseFirestore.instance
          .collection('admins')
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        return adminQuery.docs.first.get('fcmToken') as String?;
      } else {
        print('Aucun administrateur trouvé');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du FCM token de l\'admin: $e');
      return null;
    }
  }

  Widget _buildDateField(String label, DateTime? selectedDate, ValueChanged<DateTime?> onDateChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              helpText: 'Sélectionner une date',
              cancelText: 'Annuler',
              confirmText: 'Confirmer',
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != selectedDate) {
              onDateChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate)
                  : 'Sélectionner une date',
              style: TextStyle(
                fontSize: 16,
                color: selectedDate != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    try {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      print('Erreur de formatage de la date: $e');
      return 'Date non valide';
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

}