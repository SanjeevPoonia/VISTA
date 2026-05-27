import 'package:flutter/material.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
class StoreReportScreen extends StatefulWidget {
  final String reportUrl;
  const StoreReportScreen({required this.reportUrl,super.key});
  @override
  State<StoreReportScreen> createState() => _MyWebPageState();
}

class _MyWebPageState extends State<StoreReportScreen> {
  late final WebViewController _controller;
  bool isLoading = true; // loader flag

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              isLoading = false;
            });
            debugPrint("WebView error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.reportUrl)); // अपनी URL डालो
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar  (
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: AppTheme.themeColor,size: 24,),
          onPressed: () => {
            Navigator.pop(context)
          },
        ),
        backgroundColor: AppTheme.at_details_header,
        title:  Text(
          "Store performance report",
          style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.themeColor),
        ),
        /* actions: [
             IconButton(onPressed: (){
               _showAlertDialog();
             }, icon: const Icon(Icons.logout, color: AppTheme.task_Reopen_text,size: 35,))] ,*/
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) // loader overlay
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}