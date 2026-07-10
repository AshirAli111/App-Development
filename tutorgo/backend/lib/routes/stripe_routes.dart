import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/stripe_service.dart';
import '../utils/response.dart';

class StripeRoutes {
  final _stripeService = StripeService();

  Router get router {
    final router = Router();

    router.post('/create-checkout-session', _createCheckoutSession);
    router.get('/checkout/<sessionId>', _getCheckoutPage);
    router.post('/confirm/<sessionId>', _confirmPayment);
    router.get('/session/<sessionId>', _getSessionStatus);

    return router;
  }

  /// POST /api/stripe/create-checkout-session
  /// Creates a mock Stripe checkout session and returns sessionId + checkoutUrl
  Future<Response> _createCheckoutSession(Request request) async {
    try {
      final body = await parseBody(request);

      final studentId = body['studentId'] as String?;
      final tutorId = body['tutorId'] as String?;
      final amountPKR = body['amountPKR'] as int?;

      if (studentId == null || tutorId == null || amountPKR == null) {
        return errorResponse(
            'studentId, tutorId, and amountPKR are required');
      }

      if (amountPKR <= 0) {
        return errorResponse('amountPKR must be greater than 0');
      }

      final session = await _stripeService.createCheckoutSession(
        studentId: studentId,
        tutorId: tutorId,
        amountPKR: amountPKR,
        sessionInstanceId: body['sessionInstanceId'] as String?,
      );

      // Build checkout URL - client will open this in WebView
      final host = request.headers['host'] ?? 'localhost:8080';
      final scheme = host.contains('localhost') ? 'http' : 'https';
      final checkoutUrl = '$scheme://$host/api/stripe/checkout/${session['sessionId']}';

      return jsonResponse({
        'sessionId': session['sessionId'],
        'checkoutUrl': checkoutUrl,
        'amountPKR': session['amountPKR'],
        'status': session['status'],
      }, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// GET /api/stripe/checkout/:sessionId
  /// Serves the mock Stripe checkout HTML page
  Future<Response> _getCheckoutPage(Request request, String sessionId) async {
    final session = await _stripeService.getSession(sessionId);
    if (session == null) {
      return errorResponse('Session not found', statusCode: 404);
    }

    if (session['status'] == 'completed') {
      return Response.ok(_successHtml(session['amountPKR']),
          headers: {'content-type': 'text/html'});
    }

    final html = _checkoutHtml(sessionId, session['amountPKR'] as int);
    return Response.ok(html, headers: {'content-type': 'text/html'});
  }

  /// POST /api/stripe/confirm/:sessionId
  /// Confirms payment and returns success page
  Future<Response> _confirmPayment(Request request, String sessionId) async {
    final result = await _stripeService.confirmSession(sessionId);
    if (result == null) {
      return errorResponse('Session not found', statusCode: 404);
    }

    return Response.ok(_successHtml(result['amountPKR']),
        headers: {'content-type': 'text/html'});
  }

  /// GET /api/stripe/session/:sessionId
  /// Returns session status for polling
  Future<Response> _getSessionStatus(Request request, String sessionId) async {
    final session = await _stripeService.getSession(sessionId);
    if (session == null) {
      return errorResponse('Session not found', statusCode: 404);
    }

    return jsonResponse({
      'sessionId': session['sessionId'],
      'status': session['status'],
      'amountPKR': session['amountPKR'],
      'completedAt': session['completedAt'],
    });
  }

  String _checkoutHtml(String sessionId, int amountPKR) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TutorGo Payment</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #0a2540;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .checkout-card {
      background: #1a1f36;
      border-radius: 12px;
      padding: 40px;
      width: 100%;
      max-width: 420px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.4);
    }
    .header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 30px;
    }
    .logo {
      color: #635bff;
      font-size: 24px;
      font-weight: 700;
    }
    .amount {
      color: #fff;
      font-size: 28px;
      font-weight: 600;
    }
    .currency {
      color: #8792a2;
      font-size: 14px;
    }
    .form-group {
      margin-bottom: 20px;
    }
    label {
      display: block;
      color: #8792a2;
      font-size: 13px;
      font-weight: 500;
      margin-bottom: 8px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    input {
      width: 100%;
      background: #0a2540;
      border: 1px solid #30374b;
      border-radius: 8px;
      padding: 12px 16px;
      color: #fff;
      font-size: 16px;
      outline: none;
      transition: border-color 0.2s;
    }
    input:focus { border-color: #635bff; }
    input::placeholder { color: #4f5b76; }
    .row {
      display: flex;
      gap: 16px;
    }
    .row .form-group { flex: 1; }
    .pay-btn {
      width: 100%;
      background: #635bff;
      color: #fff;
      border: none;
      border-radius: 8px;
      padding: 14px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      margin-top: 10px;
      transition: background 0.2s;
    }
    .pay-btn:hover { background: #7a73ff; }
    .pay-btn:disabled {
      background: #4f5b76;
      cursor: not-allowed;
    }
    .secure {
      text-align: center;
      color: #8792a2;
      font-size: 12px;
      margin-top: 16px;
    }
    .spinner {
      display: none;
      width: 20px;
      height: 20px;
      border: 2px solid #fff;
      border-top: 2px solid transparent;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
      margin: 0 auto;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div class="checkout-card">
    <div class="header">
      <div class="logo">TutorGo Pay</div>
      <div>
        <div class="amount">PKR $amountPKR</div>
        <div class="currency">Pakistani Rupees</div>
      </div>
    </div>
    <form id="paymentForm">
      <div class="form-group">
        <label>Card Number</label>
        <input type="text" placeholder="4242 4242 4242 4242" maxlength="19" id="cardNumber">
      </div>
      <div class="row">
        <div class="form-group">
          <label>Expiry</label>
          <input type="text" placeholder="MM / YY" maxlength="7" id="expiry">
        </div>
        <div class="form-group">
          <label>CVC</label>
          <input type="text" placeholder="123" maxlength="4" id="cvc">
        </div>
      </div>
      <div class="form-group">
        <label>Cardholder Name</label>
        <input type="text" placeholder="Full name on card" id="name">
      </div>
      <button type="submit" class="pay-btn" id="payBtn">
        <span id="btnText">Pay PKR $amountPKR</span>
        <div class="spinner" id="spinner"></div>
      </button>
    </form>
    <p class="secure">🔒 Mock payment — no real charge</p>
  </div>
  <script>
    document.getElementById('paymentForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const btn = document.getElementById('payBtn');
      const btnText = document.getElementById('btnText');
      const spinner = document.getElementById('spinner');

      btn.disabled = true;
      btnText.style.display = 'none';
      spinner.style.display = 'block';

      try {
        const res = await fetch('/api/stripe/confirm/$sessionId', { method: 'POST' });
        if (res.ok) {
          document.body.innerHTML = document.createElement('div');
          document.body.innerHTML = `
            <div style="text-align:center;color:#fff;font-family:-apple-system,sans-serif;">
              <div style="font-size:64px;margin-bottom:20px;">✓</div>
              <h1 style="color:#4caf50;margin-bottom:10px;">Payment Successful</h1>
              <p style="color:#8792a2;">PKR $amountPKR has been processed</p>
              <p style="color:#8792a2;margin-top:10px;">You can close this window</p>
            </div>
          `;
        }
      } catch (err) {
        btn.disabled = false;
        btnText.style.display = 'block';
        spinner.style.display = 'none';
      }
    });
  </script>
</body>
</html>
''';
  }

  String _successHtml(dynamic amountPKR) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Payment Successful</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #0a2540;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      text-align: center;
    }
    .checkmark { font-size: 64px; margin-bottom: 20px; }
    h1 { color: #4caf50; margin-bottom: 10px; }
    p { color: #8792a2; }
  </style>
</head>
<body>
  <div>
    <div class="checkmark">✓</div>
    <h1>Payment Successful</h1>
    <p>PKR $amountPKR has been processed</p>
    <p style="margin-top:10px;">You can close this window</p>
  </div>
</body>
</html>
''';
  }
}
