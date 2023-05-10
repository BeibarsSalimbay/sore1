import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sore_beta_1/widgets/round_button.dart';
import 'package:sore_beta_1/utills/utills.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final postController =TextEditingController();
  final quantityController =TextEditingController();
  final barcodeController = TextEditingController();
  final realcoastController = TextEditingController();
  final coastController = TextEditingController();


  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
  static const Color color3 = Color(0xFF9e9e9e);
  static const Color color4 = Color(0xFFe8eaf2);

  bool loading = false ;
  final databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Цвет сканирования штрих-кода
      'Артқа қайту', // Текст кнопки отмены сканирования
      true, // Разрешение на сканирование
      ScanMode.BARCODE, // Режим сканирования
    );

    if (!mounted) return;

    setState(() {
      barcodeController.text = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: color1,
        title: Text('Зат қосу'),
      ),
      body:
      SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),

            TextFormField(
              controller: postController,
              decoration: InputDecoration(
                  hintText: 'Атауы' ,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)
                  ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: coastController,
              decoration: InputDecoration(
                hintText: 'Сатылым бағасы' ,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: realcoastController,
              decoration: InputDecoration(
                hintText: 'Көтерме бағасы' ,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              maxLines: 1,
              controller: quantityController,
              decoration: InputDecoration(
                  hintText: 'Саны' ,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              maxLines: 1,
              controller: barcodeController,
              decoration: InputDecoration(
                  hintText: 'Баркод' ,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () => _scanBarcode(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: color4,
                  fixedSize: const Size(170, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
              icon: const Icon( // <-- Icon
                Icons.fit_screen_outlined,
                size: 20.0,
                color: color1,
              ),
              label: const Text('Сканерлеу',
                  style: TextStyle(
                    color: color1,)), // <-- Text
            ),
            const SizedBox(
              height: 50,
            ),
            RoundButton(
                title: 'Қосу',
                loading: loading,
                onTap: () async {
                  setState(() {
                    loading = true ;
                  });

                  int nextOrderId = 1;

                  User user = FirebaseAuth.instance.currentUser!;
                  String uid = user.uid;


                  FirebaseDatabase.instance.reference().child('users').child(uid).child("items").orderByKey().limitToLast(1).once().then((event) {
                    if (event.snapshot.value != null) {
                      Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
                      String lastOrderId = map.keys.first;
                      nextOrderId = int.parse(lastOrderId) + 1;
                    }

                    String orderId = NumberFormat('00000000').format(nextOrderId);
                    FirebaseDatabase.instance.reference().child('users').child(uid).child("items").child(orderId).set({
                      'id' : orderId,
                      'item': postController.text.toString(),
                      'quantity': num.parse(quantityController.text),
                      'barcode': barcodeController.text.toString(),
                      'realcoast': num.parse(realcoastController.text),
                      'coast': num.parse(coastController.text),
                    }
                    ).then((value){
                      Utills().toastMessage('Тауар қосылды!');
                      setState(() {
                        loading = false ;
                      });
                    }).onError((error, stackTrace){
                      Utills().toastMessage(error.toString());
                      setState(() {
                        loading = false ;
                      });
                    });
                  });

                }
                ),
          ],
        ),
      ),
    ));

    }



}


