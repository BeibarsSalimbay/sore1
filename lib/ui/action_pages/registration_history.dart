
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';


class RegHistoryPage extends StatefulWidget {
  const RegHistoryPage({Key? key}) : super(key: key);

  @override
  State<RegHistoryPage> createState() => _RegHistoryPageState();
}

class _RegHistoryPageState extends State<RegHistoryPage> {
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
        .child('registration');

  }



  _sendPdf(DataSnapshot snapshot) async {
    // Получаем данные заказа
    List<dynamic> items = snapshot.child('items').value as List<dynamic>;
    String dateTime = snapshot.child('dateTime').value.toString();
    String totalCost = snapshot.child('totalCost').value.toString();
    String id = snapshot.child('id').value.toString();

    // Загружаем шрифт
    final ttf = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final font = pw.Font.ttf(ttf);

    // Создаем PDF документ
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          // Define the table headers
          final headers = [
            'Тауар аты',
            'Саны',
            'Бағасы, тг',
            'Барлығы, тг'
          ];

          // Define the table rows
          final rows = items.map((item) {
            String itemName = item['item'];
            int quantitySale = item['quantitySale'];
            int coast = item['coast'];
            int total = quantitySale * coast;
            return [
              itemName,
              quantitySale.toString(),
              coast.toString(),
              total.toString()
            ];
          }).toList();


          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Кіріс №$id', style: pw.TextStyle(fontSize: 20, font: font)),
              pw.SizedBox(height: 20),
              pw.Text('Уақыты: $dateTime', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: headers,
                data: rows,
                cellStyle: pw.TextStyle(font: font),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
                border: pw.TableBorder.all(width: 1, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Барлығы: $totalCost тг',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: font)),
            ],
          );
        },
      ),
    );

    // Сохраняем PDF файл на устройстве
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Zhykquzhat_$id.pdf');
    await file.writeAsBytes(await pdf.save());

    // Отправляем PDF файл через WhatsApp
    await ShareExtend.share(file.path, "file", subject: "Zhykquzhat_$id.pdf");
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
          title: Text('Кіріс №$id'),
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
              onPressed: () => _sendPdf(snapshot),
              child: Text('Жүкқұжатты жіберу'),
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
      backgroundColor: color2,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: color1,
        title: Text('Кірістер тарихы'),
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
                              Text("Кіріс №$id"),
                              Text("Барлығы: $totalCost"),

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