import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final String url;
  final String lecturerId;

  PDFViewerScreen({required this.lecturerId, required this.url});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final file = await _getPdfFile();
      setState(() {
        localFilePath = file.path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    }
  }

  Future<File> _getPdfFile() async {
    var dir = await getApplicationDocumentsDirectory();
    String savePath = '${dir.path}/temp.pdf';
    await Dio().download(widget.url, savePath);
    return File(savePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Timetable',
               style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFEDF4F2),
      body: localFilePath != null
          ? PDFView(
        filePath: localFilePath,
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
