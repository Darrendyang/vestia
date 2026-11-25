import 'dart:ui_web' as ui_web;

import 'package:web/web.dart';

import 'package:material_ui/material_ui.dart';

class Real3DViewer extends StatefulWidget {
  const Real3DViewer({super.key});

  @override
  State<Real3DViewer> createState() => _Real3DViewerState();
}

class _Real3DViewerState extends State<Real3DViewer> {
  static bool registered = false;
  static const viewType = 'vestia-3d-viewer';

  @override
  void initState() {
    super.initState();
    if (!registered) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        return HTMLIFrameElement()
          ..src = 'assets/assets/viewer/index.html'
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; gyroscope'
          ..setAttribute('title', 'Vestia 3D Style Twin');
      });
      registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewType);
  }
}
