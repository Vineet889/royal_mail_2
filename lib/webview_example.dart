import 'package:flutter/cupertino.dart';
import 'dart:html' as html;

import 'package:flutter/material.dart';

class WebviewExample extends StatefulWidget {
  const WebviewExample({super.key});

  @override
  State<WebviewExample> createState() => _WebviewExampleState();
}

class _WebviewExampleState extends State<WebviewExample> {

  String receivedMessage = 'No message yet';

  @override
  void initState(){
    super.initState();

    html.window.onMessage.listen((event){
      if(event.data is Map){
        final message = event.data['message'] ;
        setState(() {
          receivedMessage = message ?? 'No message received' ;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView JS to Dart'),
      ),
      body: Column(
        children: [
          Expanded(child: HtmlElementView(viewType: 'webview-html'),),
          Padding(padding: const EdgeInsets.all(16.0),
          child: Text('Received message: $receivedMessage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),)
        ],
      ),
    );
  }
}
