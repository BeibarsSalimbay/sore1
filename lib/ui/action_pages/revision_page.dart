import 'dart:io';

import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_extend/share_extend.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({Key? key}) : super(key: key);

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  late final DatabaseReference _itemsRef;
  late final User _user;
  List<DataRow> rows = [];
  Map<dynamic, dynamic> items = {};

  static const Color color1 = Color(0xFF13588F);
  static const Color color2 = Color(0xFF1B75C0);
  static const Color color4 = Color(0xFFe8eaf2);

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _itemsRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(_user.uid)
        .child('items');
  }

  Future<void> _shareTableAsExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    final tableHeaders = ['Тауар аты', 'Саны', 'Баркод'];
    final tableRows = items.values.map((item) {
      return [
        item['item'] ?? '',
        item['quantity']?.toString() ?? '',
        item['barcode'] ?? '',
      ];
    }).toList();

    // Write the headers
    for (var i = 0; i < tableHeaders.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = tableHeaders[i];
    }

    // Write the data rows
    for (var i = 0; i < tableRows.length; i++) {
      final row = tableRows[i];
      for (var j = 0; j < row.length; j++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1)).value = row[j];
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ревизия.xlsx');
    await file.writeAsBytes(excel.encode()!);

    ShareExtend.share(file.path, 'file', subject: "Ревизия");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color1,
        title: Text(
          'Ревизия',
          style: TextStyle(
            fontFamily: 'OpenSans-Bold',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareTableAsExcel,
          ),
        ],
      ),
      body: StreamBuilder<DataSnapshot>(
        stream: _itemsRef.onValue.asBroadcastStream().map((event) =>
        event.snapshot),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (snapshot.data!.value == null) {
            return const Text('No items found');
          }
          items = snapshot.data!.value as Map<dynamic, dynamic>;
          rows.clear();
          items.forEach((key, item) {
            final String itemName = item['item'] ?? '';
            final int itemQuantity = item['quantity'] ?? 0;
            final String barcode = item['barcode'] ?? '';
            rows.add(
              DataRow(
                cells: [
                  DataCell(Text(itemName)),
                  DataCell(Text(itemQuantity.toString())),
                  DataCell(Text(barcode)),
                ],
              ),
            );
          });
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith((
                    states) => color2),
                dataRowColor: MaterialStateColor.resolveWith((
                    states) => color4),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                columns: const [
                  DataColumn(label: Text('Тауар аты')),
                  DataColumn(label: Text('Саны')),
                  DataColumn(label: Text('Штрих-код')),
                ],
                rows: rows,
              ),
            ),
          );
        },
      ),
    );
  }
}