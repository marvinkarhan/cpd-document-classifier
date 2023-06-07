import 'dart:io';
import 'package:app/api/i_backend_service.dart';
import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewer extends StatefulWidget {
  const PDFViewer({super.key});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  String pathPDF = "";
  String id = "";
  final BackendService backendService = sl.get<BackendService>();

  Future<void> downloadFile() async {
    backendService
        .downloadDocumentById(id)
        .then((path) => setState(() => pathPDF = path));
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (id == "") {
      id = args['id'];
      downloadFile();
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text("Document Classifier"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )),
      body: pathPDF == ""
          ? const Center(child: CircularProgressIndicator())
          : Container(child: createPDFView2()),
    );
  }

  Widget createPDFView2() {
    return SfPdfViewer.file(File(pathPDF));
  }
}
