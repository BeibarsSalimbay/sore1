import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';


class OrdersBackPage extends StatefulWidget {
  const OrdersBackPage({Key? key}) : super(key: key);

  @override
  State<OrdersBackPage> createState() => _OrdersBackPageState();
}

class _OrdersBackPageState extends State<OrdersBackPage> {
  late final DatabaseReference ref;
  late final User user;
  final searchFilter = TextEditingController();

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
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
        .child('orders');
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

            ElevatedButton(
              onPressed: () async {
                // Получаем ссылки на базу данных для orders и refund
                DatabaseReference orderRef = ref.child(snapshot.key!);
                DatabaseReference refundRef = FirebaseDatabase.instance
                    .reference()
                    .child('users')
                    .child(user.uid)
                    .child('refund');
                // Получаем данные заказа
                Map<String, dynamic> data = (snapshot.value as Map)?.cast<String, dynamic>() ?? {};
                // Удаляем данные заказа из orders
                await orderRef.remove();
                // Создаем новую запись в refund с данными заказа
                refundRef.push().set(data);

                Navigator.of(context).pop();
              },
              child: Text('Қайтарым жасау'),
            ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: color1,
        title: Text('Сатылымды қайтару'),
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
                  query: ref.orderByChild('id'),
                  reverse: false,
                  defaultChild: Text('Ақпарат жүктелуде...'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final id =
                    snapshot.child('id').value.toString();
                    final totalCost =
                    snapshot.child('totalCost').value.toString();
                    final dateTime =
                    snapshot.child('dateTime').value.toString();

                    if(searchFilter.text.isEmpty){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Card(
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
                                  Text("Сатылым №$id"),
                                  Text("Суммасы: $totalCost"),

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
                            )),
                      );
                    }else if(id.toLowerCase().contains(searchFilter.text.toLowerCase().toLowerCase())){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Card(
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
                                  Text("Сатылым №$id"),
                                  Text("Суммасы: $totalCost"),

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
                            )),
                      );
                    }else{
                      return Container();
                    }
                  })
          ),
        ],
      ),
    );
  }
}