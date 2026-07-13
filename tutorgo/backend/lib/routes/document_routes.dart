import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/document_validation_service.dart';
import '../utils/response.dart';

/// Public routes for verifying tutor registration documents.
///
/// Mounted OUTSIDE the auth pipeline (like `/auth/`) because account creation is
/// deferred until the end of profile setup — a registering tutor has no access
/// token while they are still uploading their documents.
class DocumentRoutes {
  final _validator = DocumentValidationService();

  Router get router {
    final router = Router();
    router.post('/verify', _verify);
    return router;
  }

  /// Body: { type, fileBase64, mimeType } → { valid, reason }.
  Future<Response> _verify(Request request) async {
    try {
      final body = await parseBody(request);
      final type = (body['type'] as String?)?.trim();
      final fileBase64 = (body['fileBase64'] as String?)?.trim();
      final mimeType = (body['mimeType'] as String?)?.trim();

      if (type == null || type.isEmpty) {
        return errorResponse('type is required');
      }
      if (fileBase64 == null || fileBase64.isEmpty) {
        return errorResponse('fileBase64 is required');
      }
      if (mimeType == null || mimeType.isEmpty) {
        return errorResponse('mimeType is required');
      }
      if (!_validator.isSupportedType(type)) {
        return errorResponse('Unsupported document type: $type');
      }

      final result = await _validator.verify(
        type: type,
        fileBase64: fileBase64,
        mimeType: mimeType,
      );
      return jsonResponse(result);
    } on Exception catch (e) {
      // Surface as 502 so the client can distinguish an AI outage (fail-open)
      // from a bad request (400 above).
      return errorResponse(
        e.toString().replaceFirst('Exception: ', ''),
        statusCode: 502,
      );
    }
  }
}
