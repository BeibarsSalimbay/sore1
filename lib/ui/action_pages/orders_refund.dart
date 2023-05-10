import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;



class OrdersRefundPage extends StatefulWidget {
  const OrdersRefundPage({Key? key}) : super(key: key);

  @override
  State<OrdersRefundPage> createState() => _OrdersRefundPageState();
}

class _OrdersRefundPageState extends State<OrdersRefundPage> {
  late final DatabaseReference ref;
  late final User user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFFFFFFFF);
  static const Color color3 = Color(0xFF9e9e9e);
  static const Color color4 = Color(0xFFe8eaf2);

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    ref = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(user.uid)
        .child('refund');
  }


  _orderListDialog(DataSnapshot snapshot) {
    List<dynamic> items = snapshot.child('items').value as List<dynamic>;
    String dateTime = snapshot.child('dateTime').value.toString();
    String totalCost = snapshot.child('totalCost').value.toString();
    String id = snapshot.child('id').value.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Сатылым №$id'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Уақыты: $dateTime'),
              Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  String itemName = item['item'];
                  int quantitySale = item['quantitySale'];
                  int coast = item['coast'];
                  int total = quantitySale * coast;
                  return Text('$itemName, $quantitySale x $coast = $total тг');
                }).toList(),
              ),
              Divider(),
              Text('Барлығы: $totalCost тг',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Жабу'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color2,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: color1,
        title: Text('Қайтарымдар'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
              child: FirebaseAnimatedList(
                  query: ref, // Используем сортировку в зависимости от выбранного фильтра
                  reverse: false,
                  defaultChild: Text('Ақпарат жүктелуде...'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final id =
                    snapshot.child('id').value.toString();
                    final totalCost =
                    snapshot.child('totalCost').value.toString();
                    final dateTime =
                    snapshot.child('dateTime').value.toString();
                    return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant,
                          ),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Қайтарым №$id"),
                              Text("Сомасы: $totalCost"),

                            ],),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Уақыты: $dateTime"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () {
                              _orderListDialog(snapshot);
                            },),
                        ));
                  })
          ),
        ],
      ),
    );
  }
}