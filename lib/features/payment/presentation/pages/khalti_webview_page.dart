// features/payment/presentation/pages/khalti_webview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/payment/presentation/state/payment_state.dart';
import 'package:hotelspot/features/payment/presentation/view_model/payment_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KhaltiWebViewPage extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String pidx;

  const KhaltiWebViewPage({
    Key? key,
    required this.paymentUrl,
    required this.pidx,
  }) : super(key: key);

  @override
  ConsumerState<KhaltiWebViewPage> createState() => _KhaltiWebViewPageState();
}

class _KhaltiWebViewPageState extends ConsumerState<KhaltiWebViewPage> {
  late final WebViewController _controller;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Detect when Khalti redirects back to your return_url
            if (request.url.contains('/user/booking/verify') ||
                request.url.contains('status=Completed')) {
              _handlePaymentReturn(request.url);
              return NavigationDecision.prevent;
            }
            if (request.url.contains('status=User+canceled') ||
                request.url.contains('status=User canceled')) {
              _handlePaymentCancelled();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentReturn(String url) async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    // Extract pidx from URL or use stored pidx
    Uri uri = Uri.parse(url);
    final pidx = uri.queryParameters['pidx'] ?? widget.pidx;

    await ref.read(paymentViewmodelProvider.notifier).verifyPayment(pidx);

    final paymentState = ref.read(paymentViewmodelProvider);

    if (mounted) {
      if (paymentState.status == PaymentStatus.verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop back to booking history or confirmation
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentState.errorMessage ?? 'Payment verification failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _handlePaymentCancelled() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C2D91),
        elevation: 0,
        title: const Text(
          'Khalti Payment',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF1A2140),
                title: const Text(
                  'Cancel Payment?',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Are you sure you want to cancel the payment?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Color(0xFF1E90FF)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isVerifying)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF5C2D91)),
                    SizedBox(height: 16),
                    Text(
                      'Verifying payment...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
