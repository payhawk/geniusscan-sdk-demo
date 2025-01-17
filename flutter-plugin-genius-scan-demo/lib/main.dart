import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_genius_scan/flutter_genius_scan.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('GS SDK Flutter Demo'),
          ),
          body: MyScaffoldBody()),
    );
  }
}

class MyScaffoldBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
      onPressed: () async {
        try {

          // Copy OCR language file
          var languageFolder = await copyLanguageFile();

          // Initialize with your licence key
          // await FlutterGeniusScan.setLicenceKey('REPLACE_WITH_YOUR_LICENCE_KEY')

          // Start scan flow
          var scanConfiguration = {
            'source': 'camera',
            'multiPage': true,
            'ocrConfiguration': {
              'languages': ['eng'],
              'languagesDirectoryUrl': languageFolder.path
            }
          };
          var scanResult = await FlutterGeniusScan.scanWithConfiguration(scanConfiguration);

          // Here is how you can display the resulting document:
          String documentUrl = scanResult['multiPageDocumentUrl'];
          await OpenFile.open(documentUrl.replaceAll("file://", ''));

          // You can also generate your document separately from selected pages:
          /*
          var appFolder = await getApplicationDocumentsDirectory();
          var documentUrl = appFolder.path + '/mydocument.pdf';
          var document = {
            'pages': [{
              'imageUrl': scanResult['scans'][0]['enhancedUrl'] ,
              'hocrTextLayout': scanResult['scans'][0]['ocrResult']['hocrTextLayout']
            }]
          };
          var documentGenerationConfiguration = { 'outputFileUrl': documentUrl };
          await FlutterGeniusScan.generateDocument(document, documentGenerationConfiguration);
          await OpenFile.open(documentUrl);
          */

        } on PlatformException catch (error) {
          displayError(context, error);
        }
      },
      child: Text("START SCANNING"),
    ));
  }

  Future<Directory> copyLanguageFile() async {
    Directory languageFolder = await getApplicationSupportDirectory();
    File languageFile = File(languageFolder.path + "/eng.traineddata");
    if (!languageFile.existsSync()) {
      ByteData data = await rootBundle.load("assets/eng.traineddata");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await languageFile.writeAsBytes(bytes);
    }
    return languageFolder;
  }

  void displayError(BuildContext context, PlatformException error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message!)));
  }
}
