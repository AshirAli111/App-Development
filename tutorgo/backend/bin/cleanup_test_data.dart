// Removes test data from the database (users with @test.com emails)
//
// Usage: dart run bin/cleanup_test_data.dart

import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  // Read .env file for MONGO_URI
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found');
    exit(1);
  }

  final envLines = envFile.readAsLinesSync();
  String? mongoUri;
  for (final line in envLines) {
    if (line.startsWith('MONGO_URI=')) {
      mongoUri = line.substring('MONGO_URI='.length);
    }
  }

  if (mongoUri == null || mongoUri.isEmpty) {
    print('Error: MONGO_URI not found in .env');
    exit(1);
  }

  final db = await Db.create(mongoUri);
  await db.open();
  print('Connected to MongoDB');

  final users = db.collection('users');

  // Delete users with test emails (@test.com)
  final testUsers = await users.find(
    where.match('email', r'test\.com'),
  ).toList();

  if (testUsers.isEmpty) {
    print('No test users found');
  } else {
    for (final user in testUsers) {
      await users.deleteOne(where.eq('_id', user['_id']));
      print('Deleted: ${user['email']} (${user['fullName']})');
    }
    print('Deleted ${testUsers.length} test users total');
  }

  await db.close();
  print('Done');
}
