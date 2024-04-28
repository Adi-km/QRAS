






/*
class _QRPageState extends State<QRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  List<String> qrCodeList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),


       body: QRView(
         key: qrKey,
         onQRViewCreated: _onQRViewCreated,
       ),
    );
  }





  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      // Handle the scanned QR code data
      String qrCodeContent = scanData.code ?? "";

      if (qrCodeList.isEmpty) {
        // First QR code, extract size information and initialize the list
        int listSize = _getListSizeFromFirstLetter(qrCodeContent);
        qrCodeList = List.filled(listSize, "");
      } else {
        // Check if the list is not yet filled
        if (qrCodeList.contains(qrCodeContent)) {
          // Do nothing if the content is already in the list
        } else {
          // Add the content to the list
          for (int i = 0; i < qrCodeList.length; i++) {
            if (qrCodeList[i].isEmpty) {
              qrCodeList[i] = qrCodeContent;
              break;
            }
          }
        }

        // Check if the list is filled
        if (!qrCodeList.contains("")) {
          // List is filled, sort the list and stop camera
          qrCodeList.sort();
          controller.stopCamera();
          // Remove the first two characters from each element in the list
          qrCodeList = qrCodeList.map((code) => code.substring(2)).toList();

          // Add the roll number to the list
          qrCodeList.add(widget.rollNo);

          // Update the Google Sheet
          await updateGoogleSheet();
        }
      }
    });
  }
*/
