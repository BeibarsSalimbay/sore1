import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class SalePageOpen extends StatefulWidget {
  @override
  _SalePageOpenState createState() => _SalePageOpenState();
}

class _SalePageOpenState extends State<SalePageOpen> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _database = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _cartItems = [];
  double totalCost = 0;

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
  static const Color color3 = Color(0xFF9e9e9e);
  static const Color color4 = Color(0xFFe8eaf2);

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

  final databaseReference = FirebaseDatabase.instance.reference();

  void _placeOrder() {
    User user = FirebaseAuth.instance.currentUser!;
    String uid = user.uid;
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss dd.MM.yyyy').format(now);
    // Get a reference to the items node of the user's JSON structure
    DatabaseReference itemsRef = FirebaseDatabase.instance.reference().child('users').child(uid).child('items');
    FirebaseDatabase.instance.reference().child('users').child(uid).child("orders").child(id).set({
      'id' : DateTime.now().millisecondsSinceEpoch.toString(),
      'dateTime': formattedDate.toString(),
      'totalCost': totalCost,
      'items': _cartItems.map((item) {
        // Update the quantity value of the purchased item
        num quantity = item['quantity'] - item['quantitySale'];
        itemsRef.child(item['id'].toString()).update({'quantity': quantity});
        return {
          'id': item['id'],
          'item': item['item'],
          'barcode': item['barcode'],
          'coast': item['coast'],
          'quantitySale': item['quantitySale'],
        };
      }).toList(),
    }).then((value) {
      setState(() {
        _cartItems.clear();
        totalCost = 0;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сатылым жасалды!')),
      );
    }).catchError((error) {
      print('Ошибка при сохранении заказа в базе данных: $error');
    });
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

  void _addToCart(Map<String, dynamic> result) {
    final num quantitySale = int.tryParse(_quantityController.text) ?? 1;
    final num quantity = result['quantity'] ?? 0;

    if (quantitySale > quantity) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Қате!"),
            content: Text("Сатқыңыз келетін сан қол жетімді саннан көп."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("ОК"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _cartItems.add({
        'id': result['id'],
        'item': result['item'],
        'barcode': result['barcode'],
        'coast': result['coast'],
        'quantity': quantity,
        'quantitySale': quantitySale,
      });
      totalCost += result['coast'] * quantitySale;
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      final removedItem = _cartItems.removeAt(index);
      totalCost -= removedItem['coast'] * removedItem['quantitySale'];
      // Удаляем стоимость удаленного товара из общей стоимости корзины
    });
    Navigator.pop(context); // Close the current dialog
    _showCartDialog(context); // Update the cart dialog after removing an item
  }

  void _updateItem(){

  }

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Себет'),
          content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 140,
                  minWidth: double.maxFinite, // задаём максимальную ширину
                ),
                child: Column(
                  children: [
                    if (_cartItems.isNotEmpty)
                      ..._cartItems.asMap().entries.map((entry) => ListTile(
                          title: Text(entry.value['item'] ?? 'No item'),
                          subtitle: Column(
                            children: [
                              Text(entry.value['barcode']),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 170,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text('${entry.value['quantitySale']} x ${entry.value['coast']} тг = ${entry.value['coast'] * entry.value['quantitySale']} тг'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _removeFromCart(entry.key); // Вызываем функцию _removeFromCart при нажатии на IconButton
                                  },
                                ),
                              ],
                            ),
                          ))),
                    if (_cartItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Себеттің іші бос'),
                      ),
                    if (_cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Барлығы: $totalCost тг'),
                      ),
                  ],
                ),
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Жабу'),
            ),
            if (_cartItems.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _placeOrder();
                  _updateItem();
                },
                child: Text('Сатылым жасау'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color1,

        title: Text('Сатылым жасау'),
        actions: [
          GestureDetector(
            onTap: () {
              _showCartDialog(context);
            },
            child: Icon(Icons.shopping_cart,),
          ),
          const SizedBox(width: 30),
        ],
      ),
      body:
      Column(
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child:
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: 'Іздеу...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.fit_screen_outlined),
                          onPressed: _scanBarcode,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 4, color: Colors.blue),
                          borderRadius: BorderRadius.circular(25),)
                    ),
                    onChanged: (_) => _onSearchButtonPressed(),
                  ),

                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(child: Text('Нәтиже жоқ'))
                :
            ListView.builder(itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  title: Text(result['item']),
                  subtitle:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result['barcode']),
                      Text('Бағасы: ${result['coast']} тг'),
                      Text('Саны: ${result['quantity']}'),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                        children:[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.5),
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '1',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _addToCart(result);
                            },
                          ),
                        ]
                    ),
                  ),);
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            child:
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: GestureDetector(
                  onTap: () {
                    _showCartDialog(context);
                  },
                  child:Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    color: color4,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                          children:[
                            Text('Барлығы: $totalCost тг', style: TextStyle(color: color1, fontSize: 16,fontWeight: FontWeight.w600)),
                          ]
                      ),
                    ),
                  )),
            ),


          ),
        ],
      ),
    );
  }
}