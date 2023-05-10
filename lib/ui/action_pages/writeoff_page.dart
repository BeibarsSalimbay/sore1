import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class WriteoffPage extends StatefulWidget {
  @override
  _WriteoffPageState createState() => _WriteoffPageState();
}

class _WriteoffPageState extends State<WriteoffPage> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _database = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _cartItems = [];
  double totalCost = 0;
  DateTime selectedDate = DateTime.now();

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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss dd.MM.yyyy').format(now);

    DatabaseReference itemsRef = FirebaseDatabase.instance.reference().child('users').child(uid).child('items');

    int nextOrderId = 1;
    // Get a reference to the user's orders node and listen for changes to determine the next order ID
    FirebaseDatabase.instance.reference().child('users').child(uid).child("write_off").orderByKey().limitToLast(1).once().then((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        String lastOrderId = map.keys.first;
        nextOrderId = int.parse(lastOrderId) + 1;
      }

      String orderId = NumberFormat('00000000').format(nextOrderId);
      FirebaseDatabase.instance.reference().child('users').child(uid).child("write_off").child(orderId).set({
        'id' : orderId,
        'dateTime': formattedDate.toString(),
        'totalCost': totalCost,
        'items': _cartItems.map((item) {
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
          SnackBar(content: Text('Есептен шығарылды!')),
        );
      }).catchError((error) {
        print('Ошибка при сохранении заказа в базе данных: $error');
      });
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


    // Поиск товара в корзине
    final index = _cartItems.indexWhere((item) => item['id'] == result['id']);

    if (index != -1) { // товар уже есть в корзине
      setState(() {
        // Увеличиваем количество товара в корзине
        _cartItems[index]['quantitySale'] += quantitySale;
        // Обновляем общую стоимость товаров в корзине
        totalCost += result['coast'] * quantitySale;
      });
    } else { // товара еще нет в корзине
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
  }

  void _removeFromCart(int index) {
    setState(() {
      final removedItem = _cartItems.removeAt(index);
      totalCost -= removedItem['coast'] * removedItem['quantitySale'];
      // Удаляем стоимость удаленного товара из общей стоимости корзины
    });
    // Update the cart dialog after removing an item
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: color1,

        title: Text('Есептен шығару'),

      ),
      body:
      SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Күні*',
                    style: TextStyle(
                      fontFamily: 'OpenSans-Bold',
                      color: color1,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: color1,),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(1900, 1, 1),
                            maxTime: DateTime.now(),
                            onConfirm: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            currentTime: selectedDate,
                          );
                        },
                        child: Text(
                          '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(Icons.access_time, color: color1,),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          DatePicker.showTimePicker(
                            context,
                            showTitleActions: true,
                            onConfirm: (time) {
                              setState(() {
                                selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    time.hour,
                                    time.minute);
                              });
                            },
                            currentTime: selectedDate,
                          );
                        },
                        child: Text(
                          '${selectedDate.hour}:${selectedDate.minute}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 40,
              color: color1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(
                height: 140,
                child: Column(
                    children:[
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
                      SizedBox(height: 5,),
                      Expanded(
                        child: _searchResults.isEmpty
                            ? Center(child: Text(''))
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
                              ),
                            );
                          },
                        ),
                      ),
                    ])),
            Divider(
              height: 40,
              color: color1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 140,
                minWidth: double.maxFinite, // задаём максимальную ширину
              ),
              child: Column(
                children: [
                  if (_cartItems.isNotEmpty)
                    ..._cartItems.asMap().entries.map((entry) => Column(
                      children: [
                        ListTile(
                          title:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(entry.value['item'] ?? 'No item',
                                style: TextStyle(
                                  fontFamily: 'OpenSans-Bold',
                                  color: color1,
                                  fontSize: 18,
                                ),
                              ),
                              Text(entry.value['barcode'], style: TextStyle(color: Colors.black54, fontFamily: 'OpenSans-Bold',),),
                              Text('${entry.value['quantitySale']} x ${entry.value['coast']} тг = ${entry.value['coast'] * entry.value['quantitySale']} тг'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _removeFromCart(entry.key); // Вызываем функцию _removeFromCart при нажатии на IconButton
                            },),
                        ),
                        SizedBox(height: 5)
                      ],
                    )),
                  if (_cartItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(''),
                    ),
                  if (_cartItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Барлығы: $totalCost тг',
                        style: TextStyle(
                          fontFamily: 'OpenSans-Bold',
                          color: color1,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
                onTap: () {
                  _placeOrder();
                },
                child:Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  color: color1,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                        children:[
                          Text('Есептен шығару', style: TextStyle(color: color4, fontSize: 16,fontWeight: FontWeight.w600)),
                        ]
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}