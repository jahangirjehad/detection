import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show PdfPageOrientation;
import 'package:cloud_firestore/cloud_firestore.dart';

class Crystal extends StatefulWidget {
  const Crystal({Key? key}) : super(key: key);

  @override
  State<Crystal> createState() => _CrystalState();
}

class _CrystalState extends State<Crystal> {
  final pdf = pw.Document();
  List<DataRow> rows = [];
  List<dynamic> prows = [];
  dynamic withHelmet = 0;
  dynamic withOutHelmet = 0;
  dynamic totalDetection = 0;

  var w, h;

  void generatePdf() {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (pw.Context context) => [
          pw.Center(
              child: pw.Text('ML Model Table',
                  style: pw.TextStyle(
                      fontSize: 50,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black))),
          pw.Table(
            border: pw.TableBorder.all(width: 2, color: PdfColors.black),
            children: [
              pw.TableRow(children: [
                pw.Container(
                  height: 50,
                  width: w * .25,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(
                      fontSize: 25,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  height: 50,
                  width: w * .25,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Image Link',
                    style: pw.TextStyle(
                        fontSize: 25, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  height: 50,
                  width: w * .25,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Label',
                    style: pw.TextStyle(
                        fontSize: 25, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  height: 50,
                  width: w * .25,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Email',
                    style: pw.TextStyle(
                        fontSize: 25, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ]),
              for (var i = 0; i < prows.length; i++)
                pw.TableRow(children: [
                  pw.Container(
                    margin: const pw.EdgeInsets.all(2),
                    height: h * .1,
                    width: w * .30,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      prows[i][0].toString(),
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                  pw.Container(
                      margin: const pw.EdgeInsets.all(2),
                      height: h * .1,
                      width: w * .15,
                      alignment: pw.Alignment.center,
                      child: pw.UrlLink(
                          destination: prows[i][1],
                          child: pw.Text('Link',
                              style: const pw.TextStyle(
                                  fontSize: 15, color: PdfColors.blue)))),
                  pw.Container(
                    margin: const pw.EdgeInsets.all(2),
                    height: h * .1,
                    width: w * .30,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      prows[i][2].toString(),
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                  pw.Container(
                    height: h * .1,
                    width: w * .30,
                    margin: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      prows[i][3].toString(),
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ]),
            ],
          ),
          pw.SizedBox(height: h * .5),
          pw.Center(
              child: pw.Text('ML Model Summery',
                  style: pw.TextStyle(
                      fontSize: 50,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black))),
          pw.Text('Total Detect : $totalDetection',
              style: const pw.TextStyle(fontSize: 40, color: PdfColors.black)),
          pw.Text('Total With Helmet: $withHelmet',
              style: const pw.TextStyle(fontSize: 40, color: PdfColors.green)),
          pw.Text('Total With Out Helmet: $withOutHelmet',
              style: const pw.TextStyle(fontSize: 40, color: PdfColors.red)),
          pw.Center(
              child: pw.Text('ML Model Graph',
                  style: pw.TextStyle(
                      fontSize: 40,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange))),
          pw.SizedBox(height: 20),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(children: [
                  pw.Text('100%'),
                  pw.Container(height: 400, width: 100, color: PdfColors.blue),
                  pw.Text('Total Detection',
                      style: pw.TextStyle(
                          fontSize: 25,
                          color: PdfColors.blue,
                          fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(children: [
                  pw.Text('${withHelmet * 100 / totalDetection}%'),
                  pw.Container(
                      height: 400 * withHelmet / totalDetection,
                      width: 100,
                      color: PdfColors.green),
                  pw.Text('With Helmet',
                      style: pw.TextStyle(
                          fontSize: 25,
                          color: PdfColors.green,
                          fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(children: [
                  pw.Text('${withOutHelmet * 100 / totalDetection}'),
                  pw.Container(
                      height: 400 * withOutHelmet / totalDetection,
                      width: 100,
                      color: PdfColors.red),
                  pw.Text('Without Helmet',
                      style: pw.TextStyle(
                          fontSize: 25,
                          color: PdfColors.red,
                          fontWeight: pw.FontWeight.bold)),
                ]),
              ])
        ],
      ),
    );

    savePdf();
  }

  Future savePdf() async {
    final bytes = await pdf.save();
    final appDocDir = await getApplicationDocumentsDirectory();
    final pdfFile = File('${appDocDir.path}/detections_table.pdf');
    await pdfFile.writeAsBytes(bytes, flush: true);
    OpenFile.open(pdfFile.path);
    if (await pdfFile.exists()) {
      print('PDF file is successfully saved: ${pdfFile.path}');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFScreen(file: pdfFile),
        ),
      );
    } else {
      print('PDF file failed to save.');
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Detections Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('detection').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            rows.clear();
            var i = 0;
            int totalDocuments = snapshot.data!.docs.length;
            int withHelmetCount = 0;
            int withoutHelmetCount = 0;

            snapshot.data!.docs.forEach((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (data['label'] == '0 With Helmet') {
                withHelmetCount++;
              } else if (data['label'] == '1 Without Helmet') {
                withoutHelmetCount++;
              }
            });
            withHelmet = withHelmetCount;
            withOutHelmet = withoutHelmetCount;
            totalDetection = totalDocuments;
            snapshot.data!.docs.forEach((document) async {
              Map<String, dynamic> detection =
                  document.data() as Map<String, dynamic>;
              Timestamp timestamp = detection['date'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

              prows.add([
                formattedDate.toString(),
                detection['img'],
                detection['label'],
                detection['email']
              ]);

              rows.add(DataRow(cells: [
                DataCell(Text(formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.black))),
                DataCell(
                  Image.network(
                    detection['img'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                DataCell(Text(detection['label'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green))),
                DataCell(Text(detection['email'],
                    style: const TextStyle(color: Colors.blue))),
              ]));
            });

            return DataTable(
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blue),
              dataRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.white),
              headingTextStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              dataTextStyle: const TextStyle(fontSize: 12),
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Label')),
                DataColumn(label: Text('Email')),
              ],
              rows: rows,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: generatePdf,
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  var file;

  PDFScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
      ),
      body: PDFView(
        filePath: file.path,
        defaultPage: 0,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: false,
        fitEachPage: false,
        onRender: (_pages) {
          pages = _pages;
          isReady = true;
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _controller.complete(pdfViewController);
        },
        onPageChanged: (int? page, int? total) {
          print('page change: $page/$total');

          currentPage = page;
        },
      ),
    );
  }
}
