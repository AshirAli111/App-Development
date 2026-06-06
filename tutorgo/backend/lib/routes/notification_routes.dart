import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/notification_service.dart';
import '../utils/response.dart';

class NotificationRoutes {
  final _notificationService = NotificationService();

  Router get router {
    final router = Router();

    router.get('/', _getNotifications);
    router.put('/<id>/read', _markAsRead);
    router.put('/read-all', _markAllAsRead);

    return router;
  }

  Future<Response> _getNotifications(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final unreadOnly =
        request.url.queryParameters['unreadOnly'] == 'true';
    final page =
        int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;

    final notifications = await _notificationService.getUserNotifications(
      userId,
      unreadOnly: unreadOnly,
      page: page,
    );

    return jsonResponse({'notifications': notifications});
  }

  Future<Response> _markAsRead(Request request, String id) async {
    await _notificationService.markAsRead(id);
    return jsonResponse({'message': 'Notification marked as read'});
  }

  Future<Response> _markAllAsRead(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    await _notificationService.markAllAsRead(userId);
    return jsonResponse({'message': 'All notifications marked as read'});
  }
}
