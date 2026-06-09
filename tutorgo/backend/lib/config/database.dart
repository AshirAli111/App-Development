import 'package:mongo_dart/mongo_dart.dart';

class Database {
  static Db? _db;

  static Future<Db> connect(String mongoUri, String dbName) async {
    _db = await Db.create(mongoUri);
    await _db!.open();
    print('Connected to MongoDB: $dbName');
    await _createIndexes();
    return _db!;
  }

  static Db get instance {
    if (_db == null || !_db!.isConnected) {
      throw StateError('Database not connected. Call Database.connect() first.');
    }
    return _db!;
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  static Future<void> _createIndexes() async {
    final db = instance;

    // Users indexes
    await db.collection('users').createIndex(
      keys: {'email': 1},
      unique: true,
    );
    await db.collection('users').createIndex(keys: {'role': 1});
    await db.collection('users').createIndex(
      keys: {'tutorProfile.subjects': 1},
    );
    await db.collection('users').createIndex(
      keys: {'tutorProfile.isApproved': 1},
    );

    // Sessions indexes
    await db.collection('sessions').createIndex(keys: {'studentId': 1});
    await db.collection('sessions').createIndex(keys: {'tutorId': 1});
    await db.collection('sessions').createIndex(
      keys: {'recurrence.dayOfWeek': 1},
    );
    await db.collection('sessions').createIndex(keys: {'status': 1});

    // Session instances indexes
    await db.collection('session_instances').createIndex(
      keys: {'sessionId': 1},
    );
    await db.collection('session_instances').createIndex(
      keys: {'tutorId': 1, 'scheduledDate': 1},
    );
    await db.collection('session_instances').createIndex(
      keys: {'studentId': 1, 'scheduledDate': 1},
    );

    // Chats indexes
    await db.collection('chats').createIndex(keys: {'participants': 1});
    await db.collection('chats').createIndex(
      keys: {'updatedAt': -1},
    );

    // Messages indexes
    await db.collection('messages').createIndex(
      keys: {'chatId': 1, 'createdAt': 1},
    );
    await db.collection('messages').createIndex(keys: {'senderId': 1});

    // AI conversations indexes
    await db.collection('ai_conversations').createIndex(
      keys: {'userId': 1},
    );
    await db.collection('ai_conversations').createIndex(
      keys: {'updatedAt': -1},
    );

    // Notifications indexes
    await db.collection('notifications').createIndex(
      keys: {'userId': 1, 'isRead': 1},
    );
    await db.collection('notifications').createIndex(
      keys: {'userId': 1, 'scheduledFor': 1},
    );
    await db.collection('notifications').createIndex(
      keys: {'scheduledFor': 1},
    );

    // Payments indexes
    await db.collection('payments').createIndex(keys: {'studentId': 1});
    await db.collection('payments').createIndex(keys: {'tutorId': 1});
    await db.collection('payments').createIndex(keys: {'status': 1});

    // Stripe sessions indexes
    await db.collection('stripe_sessions').createIndex(
      keys: {'sessionId': 1},
      unique: true,
    );
    await db.collection('stripe_sessions').createIndex(
      keys: {'paymentId': 1},
    );
    await db.collection('stripe_sessions').createIndex(
      keys: {'studentId': 1},
    );

    print('All indexes created successfully.');
  }
}
