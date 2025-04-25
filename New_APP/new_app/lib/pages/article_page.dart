import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticlePage extends StatefulWidget {
  final String url;

  const ArticlePage({super.key, required this.url});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _hasPartialLoad = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _error = null;
              _hasPartialLoad = false;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _hasPartialLoad = true;
            });
          },
          onWebResourceError: (error) {
            print('WebView Error: Code: ${error.errorCode}, Description: ${error.description}, URL: ${widget.url}');
            setState(() {
              _isLoading = false;
              _error = 'Failed to load article: ${error.description}. Try opening in browser.';
            });
          },
        ),
      );

    // Validate and load URL
    final uri = Uri.tryParse(widget.url);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      _controller.loadRequest(
        uri,
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Cache-Control': 'no-cache',
          'DNT': '1', // Do Not Track header to avoid some tracking scripts
        },
      );
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Invalid URL: ${widget.url}. Try opening in browser.';
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasPartialLoad = false;
    });
    final uri = Uri.tryParse(widget.url);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      _controller.loadRequest(
        uri,
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Cache-Control': 'no-cache',
          'DNT': '1',
        },
      );
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Invalid URL: ${widget.url}. Try opening in browser.';
      });
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL: ${widget.url}')),
      );
      print('Invalid URL for browser: ${widget.url}');
      return;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot launch URL: ${widget.url}')),
        );
        print('Cannot launch URL: ${widget.url}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open URL: ${widget.url}')),
      );
      print('Error launching URL: $e, URL: ${widget.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
              Colors.blueGrey.shade900,
              Colors.blueGrey.shade800.withOpacity(0.9),
              Colors.blueGrey.shade900.withOpacity(0.8),
            ]
                : [
              Colors.blue.shade50,
              Colors.blue.shade100.withOpacity(0.9),
              Colors.blue.shade200.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Gradient AppBar
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
                            : [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Article',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width * 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // WebView
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                            Colors.blueGrey.shade800.withOpacity(0.3),
                            Colors.blueGrey.shade700.withOpacity(0.3),
                          ]
                              : [
                            Colors.blue.shade100.withOpacity(0.3),
                            Colors.blue.shade50.withOpacity(0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            WebViewWidget(controller: _controller),
                            if (_error != null && !_hasPartialLoad)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _error!,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _retry,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDarkMode
                                                ? Colors.blueGrey.shade700
                                                : Colors.blue.shade500,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: _openInBrowser,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDarkMode
                                                ? Colors.blue.shade700
                                                : Colors.blue.shade400,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Open in Browser'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  ),
                ],
              ),
              // Loading Indicator
              if (_isLoading)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(),
                  ).animate().fadeIn(duration: 200.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }
}