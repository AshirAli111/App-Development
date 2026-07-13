import 'package:mongo_dart/mongo_dart.dart';

import 'package:tutorgo_backend/config/database.dart';
import 'package:tutorgo_backend/config/env.dart';
import 'package:tutorgo_backend/services/ocr_results_service.dart';

/// One-off backfill for TICKET-18: tutors who registered before OCR results
/// were stored have `tutorProfile.documents` but no `ocrResults` field. This
/// OCRs their stored documents and writes the field, so the admin view is
/// complete for existing accounts too.
///
/// Usage (from backend/):
///   dart run bin/backfill_ocr_results.dart          # only tutors missing ocrResults
///   dart run bin/backfill_ocr_results.dart --force  # redo every tutor with documents
void main(List<String> args) async {
  final force = args.contains('--force');

  Env.load();
  await Database.connect(Env.mongoUri, Env.dbName);

  final users = Database.instance.collection('users');
  final ocrService = OcrResultsService();

  var query = where
      .eq('role', 'tutor')
      .exists('tutorProfile.documents');
  if (!force) {
    query = query.notExists('ocrResults');
  }

  final tutors = await users.find(query).toList();
  print('Found ${tutors.length} tutor(s) to process'
      '${force ? ' (--force)' : ''}.');

  var processed = 0;
  for (final doc in tutors) {
    final id = (doc['_id'] as ObjectId).oid;
    final name = doc['fullName'] ?? '<no name>';
    final documents = doc['tutorProfile']?['documents'];
    if (documents is! Map || documents.isEmpty) {
      print('- $name ($id): no documents, skipped');
      continue;
    }

    print('- $name ($id): OCR of ${documents.keys.join(', ')}...');
    await ocrService.processAndStore(
      userId: id,
      documents: Map<String, dynamic>.from(documents),
    );
    processed++;
  }

  print('Done. Processed $processed tutor(s).');
  await Database.close();
}
