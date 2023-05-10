import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _database = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _scanBarcode() async {
    String? barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Артқа қайту',
      true,
      ScanMode.BARCODE,
    );
    if (!mounted || barcodeScanRes == null) return;
    setState(() {
      _searchController.text = barcodeScanRes;
    });
    _onSearchButtonPressed();
  }

  void _onSearchButtonPressed() async {
    final firebaseUser = await FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid;
    if (uid == null) {
      // User not authenticated, handle it accordingly
      return;
    }
    final searchQuery = _searchController.text;

    _database
        .child('users')
        .child(uid)
        .child('items')
        .orderByChild('barcode')
        .equalTo(searchQuery)
        .once()
        .then((DatabaseEvent event1) {
      final DataSnapshot snapshot1 = event1.snapshot;
      final Map<String, dynamic>? data1 =
      Map<String, dynamic>.from(snapshot1.value as Map<dynamic, dynamic>? ?? {});

      return _database
          .child('users')
          .child(uid)
          .child('items')
          .orderByChild('item')
          .startAt(searchQuery)
          .endAt(searchQuery + "\uf8ff")
          .once()
          .then((DatabaseEvent event2) {
        final DataSnapshot snapshot2 = event2.snapshot;
        final Map<String, dynamic>? data2 =
        Map<String, dynamic>.from(snapshot2.value as Map<dynamic, dynamic>? ?? {});

        final Map<String, dynamic> combinedData = {};
        combinedData.addAll(data1 ?? {});
        combinedData.addAll(data2 ?? {});

        final List<Map<String, dynamic>> results = [];

        combinedData.forEach((key, value) {
          final item = json.decode(json.encode(value));
          results.add(item);
        });

        setState(() {
          _searchResults = results;
        });
      });
    }).catchError((error) {
      print('Search failed: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Іздеу беті'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Іздеу',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _onSearchButtonPressed,
                ),
                IconButton(
                  icon: Icon(Icons.fit_screen_outlined),
                  onPressed: _scanBarcode,
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(child: Text('Нәтиже жоқ'))
                : ListView.builder(itemCount: _searchResults.length, itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result['item'], style: TextStyle(color: Colors.blue[800], fontSize: 18,fontWeight: FontWeight.w500)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("cаны: ${result['quantity']}", style: TextStyle(color: Colors.blue[400] ,fontSize: 15,fontWeight: FontWeight.w500)),
                        Text("cатылым бағасы: ${result['coast']}", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                        Text("келу бағасы: ${result['realcoast']}", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Image.asset("assets/images/barcode.png",width: 20, height: 24),
                            Text("   ${result['barcode']}"),
                          ],
                        ),
                      ],
                    ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


