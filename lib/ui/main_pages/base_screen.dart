import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sore_beta_1/utills/utills.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);



  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late final DatabaseReference ref;
  late final User user;
  final itemController = TextEditingController();
  final quantityController = TextEditingController();
  final coastController = TextEditingController();
  final realcoastController = TextEditingController();
  final barcodeController = TextEditingController();
  final searchFilter = TextEditingController();

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);


  Future<void> _scanBarcode() async {
    String? barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Артқа қайту',
      true,
      ScanMode.BARCODE,
    );

    if (!mounted || barcodeScanRes == null) return;
    setState(() {
      searchFilter.text = barcodeScanRes;
    });

  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('items');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: color1,
        automaticallyImplyLeading: false,
        title: Text('Қойма', style: TextStyle(
          fontFamily: 'OpenSans-Bold',
        ),),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                TextFormField(
                  controller: searchFilter,
                  decoration: InputDecoration(
                    hintText: 'іздеу',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.fit_screen_outlined),
                        onPressed: _scanBarcode,),
                      border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 4, color: Colors.blue),
                      borderRadius: BorderRadius.circular(25),
                    )
                  ),
                  onChanged: (String value){
                    setState(() {
                    });
                  },
            ),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: FirebaseAnimatedList(
              query: ref,
              defaultChild: Text('Ақпарат жүктелуде...'),
              itemBuilder: (context, snapshot, animation, index) {
                final item = snapshot.child('item').value.toString();
                final quantity = snapshot.child('quantity').value.toString();
                final coast = snapshot.child('coast').value.toString();
                final realcoast = snapshot.child('realcoast').value.toString();
                final barcode = snapshot.child('barcode').value.toString();
                final id = snapshot.child('id').value.toString();

                if(searchFilter.text.isEmpty){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(item, style: TextStyle(color: color1, fontSize: 18,fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("cаны: $quantity", style: TextStyle(color: color2 ,fontSize: 15,fontWeight: FontWeight.w500)),
                                Text("cатылым бағасы: $coast тг", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                                Text("келу бағасы: $realcoast тг", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    Image.asset("assets/images/barcode.png",width: 20, height: 24),
                                    Text("   $barcode"),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) =>
                              [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showUpdateDialog(item: item,
                                        quantity: int.parse(quantity),
                                        coast: int.parse(coast),
                                        realcoast: int.parse(realcoast),
                                        barcode: int.parse(barcode),
                                        id: id,
                                      );
                                    },
                                    leading: Icon(Icons.edit),
                                    title: Text('Өзгерту'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await ref.child(id).remove();
                                    },
                                    leading: Icon(Icons.delete),
                                    title: Text('Өшіру'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  );
                }else if(item.toLowerCase().contains(searchFilter.text.toLowerCase().toLowerCase())){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(item, style: TextStyle(color: color1, fontSize: 18,fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("cаны: $quantity", style: TextStyle(color: color2 ,fontSize: 15,fontWeight: FontWeight.w500)),
                                Text("cатылым бағасы: $coast тг", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                                Text("келу бағасы: $realcoast тг", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    Image.asset("assets/images/barcode.png",width: 20, height: 24),
                                    Text("   $barcode"),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) =>
                              [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showUpdateDialog(item: item,
                                        quantity: int.parse(quantity),
                                        coast: int.parse(coast),
                                        realcoast: int.parse(realcoast),
                                        barcode: int.parse(barcode),
                                        id: id,
                                      );
                                    },
                                    leading: Icon(Icons.edit),
                                    title: Text('Өзгерту'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await ref.child(id).remove();
                                    },
                                    leading: Icon(Icons.delete),
                                    title: Text('Өшіру'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  );
                }else if(barcode.toLowerCase().contains(searchFilter.text.toLowerCase().toLowerCase())){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(item, style: TextStyle(color: color1, fontSize: 18,fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("cаны: $quantity", style: TextStyle(color: color2 ,fontSize: 15,fontWeight: FontWeight.w500)),
                                Text("cатылым бағасы: $coast тг", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                                Text("келу бағасы: $realcoast тг", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    Image.asset("assets/images/barcode.png",width: 20, height: 24),
                                    Text("   $barcode"),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) =>
                              [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showUpdateDialog(item: item,
                                        quantity: int.parse(quantity),
                                        coast: int.parse(coast),
                                        realcoast: int.parse(realcoast),
                                        barcode: int.parse(barcode),
                                        id: id,
                                      );
                                    },
                                    leading: Icon(Icons.edit),
                                    title: Text('Өзгерту'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await ref.child(id).remove();
                                    },
                                    leading: Icon(Icons.delete),
                                    title: Text('Өшіру'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  );
                } else{
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateDialog({
    required String item,
    required int quantity,
    required int realcoast,
    required int coast,
    required int barcode,
    required String id,
  }) async {
    TextEditingController itemController = TextEditingController(text: item);
    TextEditingController quantityController = TextEditingController(
        text: quantity.toString());
    TextEditingController realcoastController = TextEditingController(
        text: realcoast.toString());
    TextEditingController coastController = TextEditingController(
        text: coast.toString());
    TextEditingController barcodeController = TextEditingController(
        text: barcode.toString());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Өзгерту'),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemController,
                  decoration: const InputDecoration(),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Саны"),
                ),
                TextField(
                  controller: realcoastController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Келу бағасы"),
                ),
                TextField(
                  controller: coastController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Сатылым бағасы"),
                ),
                TextField(
                  controller: barcodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Баркод"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Артқа қайтару'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.child(id).update({
                  'item': itemController.text.toLowerCase(),
                  'quantity': int.parse(quantityController.text),
                  'realcoast': int.parse(realcoastController.text),
                  'coast': int.parse(coastController.text),
                  'barcode': int.parse(barcodeController.text),
                }).then((value) {
                  Utills().toastMessage("Сәтті өзгертілді");
                }).onError((error, stackTrace) {
                  Utills().toastMessage(error.toString());
                });
              },
              child: Text('Өзгерту'),
            )
          ],
        );
      },
    );
  }
}
