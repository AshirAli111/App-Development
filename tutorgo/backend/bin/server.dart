import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:tutorgo_backend/config/database.dart';
import 'package:tutorgo_backend/config/env.dart';
import 'package:tutorgo_backend/middleware/auth_middleware.dart';
import 'package:tutorgo_backend/routes/auth_routes.dart';
import 'package:tutorgo_backend/routes/user_routes.dart';
import 'package:tutorgo_backend/routes/session_routes.dart';
import 'package:tutorgo_backend/routes/chat_routes.dart';
import 'package:tutorgo_backend/routes/ai_routes.dart';
import 'package:tutorgo_backend/routes/notification_routes.dart';
import 'package:tutorgo_backend/routes/payment_routes.dart';
import 'package:tutorgo_backend/routes/stripe_routes.dart';
import 'package:tutorgo_backend/services/notification_service.dart';

void main() async {
  // Load environment variables
  Env.load();

  // Connect to MongoDB
  await Database.connect(Env.mongoUri, Env.dbName);

  // Start notification scheduler
  final notificationService = NotificationService();
  notificationService.startScheduler();

  // Build router
  final app = Router();

  // Public routes (no auth required)
  app.mount('/auth/', AuthRoutes().router.call);

  // Protected routes (auth required)
  final protectedRouter = Router();
  protectedRouter.mount('/users/', UserRoutes().router.call);
  protectedRouter.mount('/sessions/', SessionRoutes().router.call);
  protectedRouter.mount('/chats/', ChatRoutes().router.call);
  protectedRouter.mount('/ai/', AiRoutes().router.call);
  protectedRouter.mount('/notifications/', NotificationRoutes().router.call);
  protectedRouter.mount('/payments/', PaymentRoutes().router.call);
  protectedRouter.mount('/stripe/', StripeRoutes().router.call);

  // Apply auth middleware to protected routes
  final protectedHandler = const Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler(protectedRouter.call);

  app.mount('/api/', protectedHandler);

  // Health check
  app.get('/health', (Request request) {
    return Response.ok('{"status": "ok", "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'});
  });

  // CORS middleware
  final handler = const Pipeline()
      .addMiddleware(_corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(app.call);

  // Start server
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, Env.port);
  print('Server running on http://${server.address.host}:${server.port}');
  print('Health check: http://localhost:${Env.port}/health');

  // Handle shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down...');
    notificationService.stopScheduler();
    await Database.close();
    server.close();
    exit(0);
  });
}

Middleware _corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: _corsHeaders);
    },
  );
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, X-Requested-With',
};
