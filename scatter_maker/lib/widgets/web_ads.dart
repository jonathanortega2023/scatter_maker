import 'dart:ui_web' as ui;
import 'dart:html';
import 'package:flutter/material.dart';

const displayAdPath = "display_ads.js";

const feedAdPath = "feed_ads.js";

class DisplayWebAd extends StatelessWidget {
  const DisplayWebAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebAd(jsFilePath: displayAdPath);
  }
}

class FeedWebAd extends StatelessWidget {
  const FeedWebAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebAd(jsFilePath: feedAdPath);
  }
}

class WebAd extends StatelessWidget {
  final String jsFilePath;

  const WebAd({Key? key, required this.jsFilePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Unique identifier for the HtmlElementView
    String viewType = 'web-ad-view-${jsFilePath.hashCode}';

    // Register the view factory
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      // Create a container for the ad
      final adContainer = DivElement();

      // Create script element to load external JS file
      final scriptElement = ScriptElement()
        ..async = true
        ..src = jsFilePath
        ..crossOrigin = 'anonymous';

      // Append script element to ad container
      adContainer.children.add(scriptElement);

      // Return the container element
      return adContainer;
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      width: 1000,
      height: 300,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
