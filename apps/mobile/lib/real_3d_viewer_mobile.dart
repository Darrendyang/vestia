import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Real3DViewer extends StatefulWidget {
  const Real3DViewer({super.key});

  @override
  State<Real3DViewer> createState() => _Real3DViewerState();
}

class _Real3DViewerState extends State<Real3DViewer> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111B35))
      ..loadFlutterAsset('assets/viewer/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
