import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Download PDF from URL
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      // Save to temporary directory
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(bytes, flush: true);

      // Load into PdfController
      setState(() {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(file.path),
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading PDF: $e");
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Guide")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: _pdfController!),
    );
  }
}