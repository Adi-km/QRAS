import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gsheets/gsheets.dart';
import 'success.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_overlay.dart';
import 'package:qr4/keys/credentials.dart';

const _credentials = Credentials.credentials;



class QRPage extends StatefulWidget {
  final String rollNo;

  const QRPage({required this.rollNo, Key? key}) : super(key: key);

  @override
  State<QRPage> createState() => _QRPageState();
}
///*
class _QRPageState extends State<QRPage> {
  final MobileScannerController controller = MobileScannerController(
      autoStart: true,
    //torchEnabled: true,
    // formats: [BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
    detectionSpeed: DetectionSpeed.normal
    // detectionTimeoutMs: 1000,
    // returnImage: false,
  );
  List<String> qrCodeList = [];
  int listSize=-1;
  int c=0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Scanner"),
        //actions
      ),

      body: Stack(

      children:[
      MobileScanner(
      //fit: BoxFit.contain,
      controller: controller,
      onDetect: (capture) {


        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          debugPrint('Barcode found! ${barcode.rawValue}');
          String value = barcode.rawValue ?? "";

          if (value != ""){

            for (final barcodea in qrCodeList) {
              debugPrint('list: $barcodea');
              debugPrint('$listSize $c');
            }
              debugPrint('Barcode found! ${barcode.rawValue}');
            if (qrCodeList.isEmpty) {
              // First QR code, extract size information and initialize the list
              listSize = _getListSizeFromFirstLetter(value);
              qrCodeList = List.filled(listSize, "");
            } else {

              // Check if the list is not yet filled
              if (qrCodeList.contains(barcode.rawValue)) {
                // Do nothing if the content is already in the list
              } else {
                // Add the content to the list
                for (int i = 0; i < qrCodeList.length; i++) {
                  if (qrCodeList[i].isEmpty) {
                    qrCodeList[i] = value;
                    c+=1;
                    break;
                  }
                }
              }
            }
            if (c==listSize && !qrCodeList.contains("")){
              process(qrCodeList);

            }
          }
        }
      }
        ),
      QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.4))
    ]
    )

    )
    );
  }
//  */

void process(List<String> qrCodeList) async {
  // Sort the QR code list
  qrCodeList.sort();

  // Stop the camera controller
  controller.stop();

  // Remove the first two characters from each element in the list
  qrCodeList = qrCodeList.map((code) => code.substring(2)).toList();
  for (final barcodea in qrCodeList) {
    debugPrint('list: $barcodea');
  }


  // Add the roll number to the list
  qrCodeList.add(widget.rollNo);
  debugPrint("AAAAAA");

  // Update the Google Sheet
  await updateGoogleSheet(qrCodeList);
}

  int _getListSizeFromFirstLetter(String firstLetter) {
    // Assuming first letter 'a' means list size 1, 'b' means list size 2, and so on...
    return firstLetter.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
  }




  Future<void> updateGoogleSheet(List<String> qrCodeList) async {
    try {
      // Initialize GSheets with credentials
      const credentials = _credentials;
      final gsheets = GSheets(credentials);
      for (final barcodea in qrCodeList) {
        debugPrint('list: $barcodea');
      }


      // As summing qrCodeList contains Spreadsheet ID at index 0 and date at index 1
      final spreadsheetId = qrCodeList[0];
      final date = qrCodeList[1];
      final pin = qrCodeList[2];


      // Open the spreadsheet
      final ss = await gsheets.spreadsheet(spreadsheetId);

      // Get the sheet (assuming it's the first sheet)
      final sheet = ss.sheets[0];

      // Find the row index for rollNo
      int row = 1; // Start from the first row
      int flag =0;
      final rollNoColumn = await sheet.values.column(1);
      for (final cellValue in rollNoColumn) {
        if (cellValue.toLowerCase() == widget.rollNo.toLowerCase()) {
          flag =1;
          break;
        }
        row++;
      }

      if (flag == 0){
        await sheet.values.insertValue(widget.rollNo.toUpperCase(), column: 1, row: row);
      }
      debugPrint("$row");

      // Find the column index for date
      int col = 1; // Start from the first column
      final dateRow = await sheet.values.row(1);
      for (final cellValue in dateRow) {
        if (cellValue == date) {
          break;
        }
        col++;
      }
      debugPrint("$col");


      // Update the cell with 'P'

      if ((await sheet.values.value(column: col, row: 2) == pin) || await sheet.values.value(column: col+1, row: 2) == pin) {
        await sheet.values.insertValue('P', column: col, row: row);
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuccessPage(attendanceMarked: true),
          ),
        );
      } else {
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuccessPage(attendanceMarked: false),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating Google Sheet: $e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessPage(attendanceMarked: false),
        ),
      );
    }
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }
}



