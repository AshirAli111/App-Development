import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/payment_service.dart';
import '../utils/response.dart';

class PaymentRoutes {
  final _paymentService = PaymentService();

  Router get router {
    final router = Router();

    router.get('/', _getPayments);
    router.post('/', _createPayment);
    router.get('/summary', _getSummary);
    router.put('/<id>/status', _updateStatus);

    return router;
  }

  Future<Response> _getPayments(Request request) async {
    final userId = request.headers['x-user-id'];
    final role = request.headers['x-user-role'];
    if (userId == null || role == null) {
      return errorResponse('Unauthorized', statusCode: 401);
    }

    final page =
        int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;

    final payments = await _paymentService.getPaymentsByUser(
      userId,
      role,
      page: page,
    );

    return jsonResponse({'payments': payments});
  }

  Future<Response> _createPayment(Request request) async {
    try {
      final body = await parseBody(request);

      final studentId = body['studentId'] as String?;
      final tutorId = body['tutorId'] as String?;
      final amountPKR = body['amountPKR'] as int?;
      final method = body['method'] as String?;

      if (studentId == null || tutorId == null || amountPKR == null || method == null) {
        return errorResponse('studentId, tutorId, amountPKR, and method are required');
      }

      final validMethods = ['cash', 'bank_transfer', 'easypaisa', 'jazzcash', 'stripe'];
      if (!validMethods.contains(method)) {
        return errorResponse('method must be one of: ${validMethods.join(", ")}');
      }

      final payment = await _paymentService.createPayment(
        studentId: studentId,
        tutorId: tutorId,
        sessionInstanceId: body['sessionInstanceId'] as String?,
        amountPKR: amountPKR,
        method: method,
      );

      return jsonResponse(payment, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _getSummary(Request request) async {
    final userId = request.headers['x-user-id'];
    final role = request.headers['x-user-role'];
    if (userId == null || role == null) {
      return errorResponse('Unauthorized', statusCode: 401);
    }

    final summary = await _paymentService.getPaymentSummary(userId, role);
    return jsonResponse(summary);
  }

  Future<Response> _updateStatus(Request request, String id) async {
    try {
      final body = await parseBody(request);
      final status = body['status'] as String?;

      if (status == null) {
        return errorResponse('status is required');
      }

      await _paymentService.updatePaymentStatus(id, status);
      return jsonResponse({'message': 'Payment status updated'});
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
