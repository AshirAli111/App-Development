import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class StripeCheckoutScreen extends StatefulWidget {
  final String studentId;
  final String tutorId;
  final int amountPKR;
  final String? sessionInstanceId;
  final String baseUrl;
  final String token;

  const StripeCheckoutScreen({
    super.key,
    required this.studentId,
    required this.tutorId,
    required this.amountPKR,
    this.sessionInstanceId,
    required this.baseUrl,
    required this.token,
  });

  @override
  State<StripeCheckoutScreen> createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  late WebViewController _webViewController;
  String? _sessionId;
  String? _checkoutUrl;
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _createCheckoutSession();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _createCheckoutSession() async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/api/stripe/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'studentId': widget.studentId,
          'tutorId': widget.tutorId,
          'amountPKR': widget.amountPKR,
          if (widget.sessionInstanceId != null)
            'sessionInstanceId': widget.sessionInstanceId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _sessionId = data['sessionId'];
          _checkoutUrl = data['checkoutUrl'];
          _isLoading = false;
        });
        _initWebView();
        _startPolling();
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['error'] ?? 'Failed to create checkout session';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            // Check if we're on the success page
            if (url.contains('/confirm/')) {
              _onPaymentSuccess();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_checkoutUrl!));
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_sessionId == null) return;

      try {
        final response = await http.get(
          Uri.parse('${widget.baseUrl}/api/stripe/session/$_sessionId'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'completed') {
            _pollTimer?.cancel();
            _onPaymentSuccess();
          }
        }
      } catch (_) {}
    });
  }

  void _onPaymentSuccess() {
    _pollTimer?.cancel();
    if (!mounted) return;

    Navigator.of(context).pop(true); // Return true = payment success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with Card'),
        backgroundColor: const Color(0xFF0A2540),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF635BFF)),
            SizedBox(height: 16),
            Text('Creating checkout session...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _createCheckoutSession();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return WebViewWidget(controller: _webViewController);
  }
}
