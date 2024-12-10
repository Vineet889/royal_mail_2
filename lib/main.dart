import 'package:demo_rm/webview_example.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  // html.window.customElements?.define('webview-html',html.IFrameElement()..src ='assets/webview.html'..style.border = 'none');
  ui.platformViewRegistry.registerViewFactory(
      'webview-html',
          (int viewId) => html.IFrameElement()
        ..width = '640'
        ..height = '360'
        ..src = 'assets/webview.html'
        ..style.border = 'none');
  runApp(MaterialApp(home: WebviewExample()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}




