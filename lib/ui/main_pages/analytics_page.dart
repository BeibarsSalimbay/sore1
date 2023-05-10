import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int itemCount = 0;
  num totalQuantity = 0;
  num totalCoast = 0;
  num orderTotalCost = 0;
  num totalQuantitySale = 0;
  num totalSalesDay = 0;
  num totalSalesWeek = 0;
  num totalSalesMonth = 0;

  List<MapEntry<String, int>> mostFrequentItems = [];
  List<MapEntry<String, int>> mostFrequentItemsWeek = [];


  List<_SalesData> data1 = [
    _SalesData('10:00', 32000),
    _SalesData('12:00', 33000),
    _SalesData('15:00', 34000),
    _SalesData('18:00', 39000),
    _SalesData('21:00', 45000)
  ];
  List<_SalesData> data2 = [
    _SalesData('10:00', 22000),
    _SalesData('12:00', 23000),
    _SalesData('15:00', 24000),
    _SalesData('18:00', 29000),
    _SalesData('21:00', 25000)
  ];
  List<_SalesData> data3 = [
    _SalesData('21.04', 420000),
    _SalesData('22.04', 430000),
    _SalesData('23.04', 440000),
    _SalesData('24.04', 490000),
    _SalesData('25.04', 450000)
  ];
  List<_SalesData> data4 = [
    _SalesData('21.04', 320000),
    _SalesData('22.04', 330000),
    _SalesData('23.04', 340000),
    _SalesData('24.04', 390000),
    _SalesData('25.04', 450000)
  ];
  List<_SalesData> data5 = [
    _SalesData('Қаңтар', 420000),
    _SalesData('Ақпан', 350000),
    _SalesData('Наурыз', 470000),
    _SalesData('Сәуір', 440000),
    _SalesData('Мамыр', 550000)
  ];
  List<_SalesData> data6 = [
    _SalesData('Қаңтар', 320000),
    _SalesData('Ақпан', 330000),
    _SalesData('Наурыз', 340000),
    _SalesData('Сәуір', 390000),
    _SalesData('Мамыр', 450000)
  ];

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF3a5f6f);
  static const Color color3 = Color(0xffcb7600);


  final User? user = FirebaseAuth.instance.currentUser;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getItemCount();
    _getTotalQuantity();
    _getTotalCoast();
    _getTotalOrder();
    _getTotalQuantitySale();
    _getBestSeller();
    _getBestSellerWeek();
    _getTotalSalesDay();
    _getTotalSalesWeek();
    _getTotalSalesMonth();
  }

  Future<void> _getItemCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/items').onValue.listen((event) {
        final Map<dynamic, dynamic>? value = event.snapshot.value as Map?;
        if (value != null) {
          setState(() {
            itemCount = value.length;
          });
        }
      });
    }
  }
  Future<void> _getTotalQuantity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/items').onValue.listen((event) {
        final value = event.snapshot.value as Map?;
        if (value != null) {
          num sum = 0;
          value.forEach((key, item) {
            final quantity = int.tryParse(item['quantity'].toString() ?? '') ?? 0;
            if (quantity != null) {
              sum += quantity;
            }
          });
          setState(() {
            totalQuantity = sum;
          });
        }
      });
    }
  }
  Future<void> _getTotalCoast() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/items').onValue.listen((event) {
        final value = event.snapshot.value as Map?;
        if (value != null) {
          num sum = 0;
          value.forEach((key, item) {
            final coast = int.tryParse(item['coast'].toString() ?? '') ?? 0;
            final quantity = int.tryParse(item['quantity'].toString() ?? '') ?? 1;
            if (coast != null) {
              sum += coast * quantity;
            }
          });
          setState(() {
            totalCoast = sum;
          });
        }
      });
    }
  }
  Future<void> _getTotalOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/orders').onValue.listen((event) {
        final value = event.snapshot.value as Map?;
        if (value != null) {
          num sum = 0;
          value.forEach((key, order) {
            final totalCost = order['totalCost'] as int?;
            if (totalCost != null) {
              sum += totalCost;
            }
          });
          setState(() {
            orderTotalCost = sum;
          });
        }
      });
    }
  }
  Future<void> _getTotalQuantitySale() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      database.child('users/${user.uid}/orders').onValue.listen((event) {
        final value = event.snapshot.value as Map?;
        if (value != null) {
          num sum = 0;
          value.forEach((key, order) {
            if (order['items'] != null) {
              order['items'].forEach((item) {
                final quantitySale = item['quantitySale'] as int?;
                if (quantitySale != null) {
                  sum += quantitySale;
                }
              });
            }
          });
          setState(() {
            totalQuantitySale = sum;
          });
        }
      });
    }
  }

  Future<void> _getBestSeller() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      final bestSellers = <String, int>{};
      for (int i = 0; i < 7; i++) {
        DateTime date = DateTime.now().subtract(Duration(days: i));
        String formattedDate = DateFormat('yyyyMMdd').format(date);
        await database.child('users/${user.uid}/orders/$formattedDate').once().then((snapshot) {
          final value = snapshot.snapshot.value as Map?;
          if (value != null) {
            value.forEach((key, order) {
              if (order['items'] != null) {
                order['items'].forEach((item) {
                  final itemId = item['item'] as String?;
                  final quantitySold = item['quantitySale'] as int?;
                  if (itemId != null && quantitySold != null) {
                    bestSellers.update(itemId, (value) => value + quantitySold,
                        ifAbsent: () => quantitySold);
                  }
                });
              }
            });
          }
        }).catchError((error) {
          print('Error getting sales data for $formattedDate: $error');
        });
      }
      final sortedBestSellers = bestSellers.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      setState(() {
        mostFrequentItems = sortedBestSellers;
      });
    }
  }
  Future<void> _getBestSellerWeek() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final database = FirebaseDatabase.instance.reference();
      final bestSellers = <String, int>{};
      for (int i = 0; i < 30; i++) {
        DateTime date = DateTime.now().subtract(Duration(days: i));
        String formattedDate = DateFormat('yyyyMMdd').format(date);
        await database.child('users/${user.uid}/orders/$formattedDate').once().then((snapshot) {
          final value = snapshot.snapshot.value as Map?;
          if (value != null) {
            value.forEach((key, order) {
              if (order['items'] != null) {
                order['items'].forEach((item) {
                  final itemId = item['item'] as String?;
                  final quantitySold = item['quantitySale'] as int?;
                  if (itemId != null && quantitySold != null) {
                    bestSellers.update(itemId, (value) => value + quantitySold,
                        ifAbsent: () => quantitySold);
                  }
                });
              }
            });
          }
        }).catchError((error) {
          print('Error getting sales data for $formattedDate: $error');
        });
      }
      final sortedBestSellers = bestSellers.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      setState(() {
        mostFrequentItemsWeek = sortedBestSellers;
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
  Future<void> _getTotalSalesWeek() async {
    DateTime now = DateTime.now();
    DateTime lastWeek = now.subtract(Duration(days: 7));

    num sum = 0;
    for (int i = 0; i < 7; i++) {
      DateTime date = lastWeek.add(Duration(days: i));
      String formattedDate = DateFormat('yyyyMMdd').format(date);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final database = FirebaseDatabase.instance.reference();
        database
            .child('users/${user.uid}/orders/$formattedDate')
            .once()
            .then((snapshot) {
          final value = snapshot.snapshot.value as Map?;
          if (value != null) {
            value.forEach((key, order) {
              final totalCost = order['totalCost'] as int?;
              if (totalCost != null) {
                sum += totalCost;
              }
            });
          }
          setState(() {
            totalSalesWeek = sum;
          });
        }).catchError((error) {
          print('Error getting sales data for $formattedDate: $error');
        });
      }
    }
  }
  Future<void> _getTotalSalesMonth() async {
    DateTime now = DateTime.now();
    DateTime lastWeek = now.subtract(Duration(days: 10));

    num sum = 0;
    for (int i = 0; i < 10; i++) {
      DateTime date = lastWeek.add(Duration(days: i));
      String formattedDate = DateFormat('yyyyMMdd').format(date);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final database = FirebaseDatabase.instance.reference();
        database
            .child('users/${user.uid}/orders/$formattedDate')
            .once()
            .then((snapshot) {
          final value = snapshot.snapshot.value as Map?;
          if (value != null) {
            value.forEach((key, order) {
              final totalCost = order['totalCost'] as int?;
              if (totalCost != null) {
                sum += totalCost;
              }
            });
          }
          setState(() {
            totalSalesMonth = sum;
          });
        }).catchError((error) {
          print('Error getting sales data for $formattedDate: $error');
        });
      }
    }
  }

  int _selectedIndex = 0;
  int _selectedIndex1 = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: color1,
          automaticallyImplyLeading: false,
          title: Text('Анализ беті',
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
                const SizedBox(height: 10),
                Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text("Қозғалыс графигi",style: TextStyle(color: color2, fontSize: 19,fontWeight: FontWeight.w400)),
                    )),
                IndexedStack(
                  index: _selectedIndex,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries<_SalesData, String>>[
                            SplineSeries<_SalesData, String>(
                              name: 'Sales 1',
                              dataSource: data1,
                              xValueMapper: (_SalesData sales, _) => sales.year,
                              yValueMapper: (_SalesData sales, _) => sales.sales,
                              color: Colors.blue,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.auto,
                                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                            ),
                            SplineSeries<_SalesData, String>(
                              name: 'Sales 2',
                              dataSource: data2,
                              xValueMapper: (_SalesData sales, _) => sales.year,
                              yValueMapper: (_SalesData sales, _) => sales.sales,
                              color: Colors.red,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.auto,
                                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries<_SalesData, String>>[
                          SplineSeries<_SalesData, String>(
                            name: 'Sales 1',
                            dataSource: data3,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            color: Colors.blue,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                          ),
                          SplineSeries<_SalesData, String>(
                            name: 'Sales 3',
                            dataSource: data4,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            color: Colors.red,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries<_SalesData, String>>[
                          SplineSeries<_SalesData, String>(
                            name: 'Sales 1',
                            dataSource: data5,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            color: Colors.blue,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                          ),
                          SplineSeries<_SalesData, String>(
                            name: 'Sales 3',
                            dataSource: data6,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            color: Colors.red,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Text('Күніне', style: TextStyle(fontSize: 15, fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        color: _selectedIndex == 0 ? Colors.blue : Colors.black,),),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Text('Аптасына', style: TextStyle(fontSize: 15, fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        color: _selectedIndex == 1 ? Colors.blue : Colors.black,),),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                      child: Text('Айына', style: TextStyle(fontSize: 15, fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                        color: _selectedIndex == 2 ? Colors.blue : Colors.black,),),
                    ),
                  ],
                ),
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            children: [
                              Text("Сатылымдар - ",style: TextStyle(color: color2, fontSize: 16,fontWeight: FontWeight.w400)),
                              Icon(Icons.circle, size: 15,color: Colors.blue),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            children: [
                              Text("Кірістер - ",style: TextStyle(color: color2, fontSize: 16,fontWeight: FontWeight.w400)),
                              Icon(Icons.circle, size: 15,color: Colors.red),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),
                Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text("Жиі сатылатын заттар",style: TextStyle(color: color2, fontSize: 18,fontWeight: FontWeight.w400,)),
                    )),
                const SizedBox(height: 10),
                IndexedStack(
                    index: _selectedIndex1,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          height: 250.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [],
                            ),
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              series: <ChartSeries<MapEntry<String, int>, String>>[
                                ColumnSeries<MapEntry<String, int>, String>(
                                  dataSource: mostFrequentItems.take(5).toList(),
                                  xValueMapper: (item, _) => item.key,
                                  yValueMapper: (item, _) => item.value,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment: ChartDataLabelAlignment.middle,
                                    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    labelPosition: ChartDataLabelPosition.outside,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SizedBox(
                              height: 250.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),

                                  boxShadow: [],
                                ),
                                child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  series: <ChartSeries<MapEntry<String, int>, String>>[
                                    ColumnSeries<MapEntry<String, int>, String>(
                                      dataSource: mostFrequentItemsWeek.take(5).toList(),
                                      xValueMapper: (item, _) => item.key,
                                      yValueMapper: (item, _) => item.value,
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        labelAlignment: ChartDataLabelAlignment.middle,
                                        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        labelPosition: ChartDataLabelPosition.outside,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex1 = 0;
                        });
                      },
                      child: Text('Апта',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _selectedIndex1 == 0 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedIndex1 == 0 ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex1 = 1;
                        });
                      },
                      child: Text('Ай',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _selectedIndex1 == 1 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedIndex1 == 1 ? Colors.blue : Colors.black,
                        ),

                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text("Қойманы бағалау",style: TextStyle(color: color2, fontSize: 19,fontWeight: FontWeight.w400)),
                    )),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF598DFF),
                                  Color(0xFF598DFF),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Тауар сомасы',
                                  style: TextStyle(fontSize: 16, color:  Color(0xFFFFFFFF),fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$totalCoast тг',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8C9FFD),
                                  Color(0xFF8C9FFD),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  ' Зат саны',
                                  style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF),fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$totalQuantity',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF80A474),
                                  Color(0xFF80A474),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Тауар түрі',
                                  style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF),fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
                Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text("Сатылымдар туралы ақпараттар",style: TextStyle(color: color2, fontSize: 18,fontWeight: FontWeight.w400)),
                    )),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF7EA3),
                                  Color(0xFFFF7EA3),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Сатылымдар сомасы',
                                  style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF),fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$orderTotalCost тг',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFCC66FF),
                                  Color(0xFFCC66FF),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Сатылған зат саны',
                                  style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF),fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$totalQuantitySale',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  thickness: 1,
                  indent: 50,
                  endIndent: 50,
                  color: color2,
                ),



              ],
            ),
          ),
        )
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
