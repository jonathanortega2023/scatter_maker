import 'dart:ui_web' as ui;
import 'dart:html';
import 'package:flutter/material.dart';

const displayAdSource = '''
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3606561568928972"
     crossorigin="anonymous"></script>
<!-- scatter-maker-ad -->
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-3606561568928972"
     data-ad-slot="5109743210"
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
''';

const feedAdSource = '''
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3606561568928972"
     crossorigin="anonymous"></script>
<ins class="adsbygoogle"
     style="display:block"
     data-ad-format="fluid"
     data-ad-layout-key="-6t+ed+2i-1n-4w"
     data-ad-client="ca-pub-3606561568928972"
     data-ad-slot="6191724743"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
''';

class DisplayWebAd extends StatelessWidget {
  const DisplayWebAd({super.key});

  @override
  Widget build(BuildContext context) {
    // Unique identifier for the HtmlElementView
    String viewType = 'web-ad-view';

    // Register the view factory
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      // Create a container for the ad
      final adContainer = DivElement();

      // Insert the ad HTML into the container
      adContainer.setInnerHtml(displayAdSource,
          treeSanitizer: NodeTreeSanitizer.trusted);
      // Return the container element
      return adContainer;
    });

    return HtmlElementView(viewType: viewType);
  }
}

class FeedWebAd extends StatelessWidget {
  const FeedWebAd({super.key});

  @override
  Widget build(BuildContext context) {
    // Unique identifier for the HtmlElementView
    String viewType = 'web-ad-view';

    // Register the view factory
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      // Create a container for the ad
      final adContainer = DivElement();

      // Insert the ad HTML into the container
      adContainer.setInnerHtml(feedAdSource,
          treeSanitizer: NodeTreeSanitizer.trusted);
      // Return the container element
      return adContainer;
    });

    return HtmlElementView(viewType: viewType);
  }
}
