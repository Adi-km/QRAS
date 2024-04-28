
import 'package:gsheets/gsheets.dart';
import 'package:qr4/keys/credentials.dart';





const _credentials=Credentials.credentials;
const _spreadsheetID =Credentials.spreadsheetID;



void main() async {
  final gsheets=GSheets(_credentials);
  final ss= await gsheets.spreadsheet(_spreadsheetID);

  var sheet = ss.worksheetByTitle("Sheet1");


}



