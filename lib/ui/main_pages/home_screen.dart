import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sore_beta_1/ui/action_pages/add_item.dart';
import 'package:sore_beta_1/ui/action_pages/orders_back.dart';
import 'package:sore_beta_1/ui/action_pages/registration_history.dart';
import 'package:sore_beta_1/ui/action_pages/registration_page.dart';
import 'package:sore_beta_1/ui/action_pages/revision_page.dart';
import 'package:sore_beta_1/ui/action_pages/sale_page.dart';
import 'package:sore_beta_1/ui/action_pages/writeoff_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../utills/utills.dart';
import '../action_pages/orders_page.dart';
import '../action_pages/orders_refund.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
  static const Color color5 = Color(0xff494033);
  static const Color color6 = Color(0xffa26a02);
  static const Color color7 = Color(0xFFF4F9FF);

  final User? user = FirebaseAuth.instance.currentUser;
  final auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  final database = FirebaseDatabase.instance.reference();

  String? _companyName;

  num totalSalesDay = 0;
  num totalSalesDayCash = 0;
  num totalSalesDayKaspi = 0;
  num totalSalesDayCard = 0;


  @override
  void initState() {
    super.initState();
    getUserFullName();
    _getTotalSalesDay();
    _getTotalSalesDayPay();
  }

  Future<void> getUserFullName() async {
    final user = auth.currentUser;
    if (user != null) {
      final query = database.child('users').child(user.uid);
      query.onValue.listen((event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          final userData =
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
          setState(() {
            _companyName = userData['companyName'];
          });
        }
      }, onError: (error) {
        Utills().toastMessage(error.toString());
      });
    }
  }

  Future<void> _getTotalSalesDayPay() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMdd').format(now);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/orders/$formattedDate').once().then((snapshot) {
        final value = snapshot.snapshot.value as Map?;
        if (value != null) {
          num sumCash = 0;
          num sumKaspi = 0;
          num sumCard = 0;
          value.forEach((key, order) {
            final totalCost = order['totalCost'] as int?;
            final paymentMethod = order['paymentMethod'] as String?;
            if (totalCost != null && paymentMethod != null) {
              switch (paymentMethod) {
                case 'cash':
                  sumCash += totalCost;
                  break;
                case 'kaspi':
                  sumKaspi += totalCost;
                  break;
                case 'card':
                  sumCard += totalCost;
                  break;
              }
            }
          });
          setState(() {
            totalSalesDayCash = sumCash;
            totalSalesDayKaspi = sumKaspi;
            totalSalesDayCard = sumCard;
          });
        }
      });
    }
  }

  Future<void> _getTotalSalesDay() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMdd').format(now);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/orders/$formattedDate').once().then((snapshot) {
        final value = snapshot.snapshot.value as Map?;
        if (value != null) {
          num sum = 0;
          value.forEach((key, order) {
            final totalCost = order['totalCost'] as int?;
            if (totalCost != null) {
              sum += totalCost;
            }
          });
          setState(() {
            totalSalesDay = sum;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'assets/images/i_10.jpg',
      'assets/images/i_11.jpg',
      'assets/images/i_12.jpg',
      'assets/images/i_13.jpg',
    ];

    final List<Widget> imageSliders = imgList.map((item) => Container(child: Container(margin: EdgeInsets.all(5.0),
      child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(20.0)),
        child: Stack(
            children: <Widget>[
              Image.asset(item, fit: BoxFit.cover, width: 800.0),
            ],
          ),
        ),
    ),
    )).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: color1,
        automaticallyImplyLeading: false,
        title: Text('$_companyName',
          style: TextStyle(
          fontFamily: 'OpenSans-Bold',
        ),),
      ),
      body:
      SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: SizedBox(
                            height: 200.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [],
                              ),
                              child: SfCircularChart(
                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.right,
                                  textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                series: <CircularSeries>[
                                  PieSeries<MapEntry<String, num>, String>(
                                    dataSource: <MapEntry<String, num>>[
                                      MapEntry<String, num>('Қолма-қол', totalSalesDayCash),
                                      MapEntry<String, num>('Kaspi', totalSalesDayKaspi),
                                      MapEntry<String, num>('Банк картасы', totalSalesDayCard),
                                    ],
                                    pointColorMapper: (entry, _) => entry.key == 'Қолма-қол' ? Colors.green[600] :
                                    entry.key == 'Kaspi' ? Colors.red[500] :
                                    Color(0xFF13588F),
                                    xValueMapper: (entry, _) => entry.key,
                                    yValueMapper: (entry, _) => entry.value,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      labelAlignment: ChartDataLabelAlignment.middle,
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Бүгінгі сатлылым:',
                              style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '$totalSalesDay тг',
                              style: const TextStyle(
                                color: Color(0xFF234157),
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child:
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            child: InkWell(
                              onTap: () {
                                if (user?.uid != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SalePage()),
                                  );
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.add_shopping_cart, size: 35,color: color5),
                                  Text(
                                    'Сатылым\nжасау',
                                    style: TextStyle(fontSize: 14, color: color5,fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(

                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrdersBackPage()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.refresh, size: 35,color: color6),
                                  Text(
                                    'Қайтарым\nжасау',
                                    style: TextStyle(fontSize: 14,color: color6,fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddItemScreen()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.add, size: 35,color: Colors.green[900]),
                                  Text(
                                    'Тауар\nқосу',
                                    style: TextStyle(fontSize: 14,color: Colors.green[900],fontWeight: FontWeight.w400 ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegPage()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.assignment_returned_rounded, size: 35,color: Colors.amber[900]),
                                  Text(
                                    'Есепке\nалу',
                                    style: TextStyle(fontSize: 14,color: Colors.amber[900],fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WriteoffPage()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.remove_shopping_cart_outlined, size: 35,color: Colors.red[600]),
                                  Text(
                                    'Есептен\nшығару',
                                    style: TextStyle(fontSize: 14,color: Colors.red[600],fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RevisionScreen()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.list_alt_sharp, size: 35,color: Colors.green[600]),
                                  Text(
                                    'Ревизизя\nжасау',
                                    style: TextStyle(fontSize: 14,color: Colors.green[600],fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegHistoryPage()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.assignment_returned_rounded, size: 35,color: Colors.blue[700]),
                                  Text(
                                    'Кіріс\nтарихы',
                                    style: TextStyle(fontSize: 14,color: Colors.blue[700],fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrdersPage()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.shopping_cart, size: 35,color: Colors.blue[700]),
                                  Text(
                                    'Сатылымдар\nтарихы',
                                    style: TextStyle(fontSize: 14,color: Colors.blue[700],fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrdersRefundPage()),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.refresh, size: 35,color: Colors.blue[700]),
                                  Text(
                                    'Қайтарымдар\nтарихы',
                                    style: TextStyle(fontSize: 14,color: Colors.blue[700],fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20)
              ],
          ),
      ),
      )
      );
  }
}