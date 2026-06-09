import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/user_model.dart';

class UserService {
  DbCollection get _users => Database.instance.collection('users');

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _users.findOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
    );
    if (doc == null) return null;
    return UserModel.fromMap(doc).toPublicMap();
  }

  Future<Map<String, dynamic>?> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    // Remove fields that shouldn't be updated directly
    updates.remove('_id');
    updates.remove('email');
    updates.remove('password');
    updates.remove('role');
    updates.remove('createdAt');
    updates['updatedAt'] = DateTime.now();

    final modifier = ModifierBuilder();
    updates.forEach((key, value) {
      modifier.set(key, value);
    });

    await _users.updateOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
      modifier,
    );

    return getUserById(userId);
  }

  Future<List<Map<String, dynamic>>> getTutors({
    String? subject,
    int page = 1,
    int limit = 20,
  }) async {
    var query = where.eq('role', 'tutor').eq('tutorProfile.isApproved', true);

    if (subject != null && subject.isNotEmpty) {
      query = query.eq('tutorProfile.subjects', subject);
    }

    final skip = (page - 1) * limit;
    final docs = await _users
        .find(query.skip(skip).limit(limit))
        .toList();

    return docs.map((doc) => UserModel.fromMap(doc).toPublicMap()).toList();
  }

  Future<Map<String, dynamic>?> getTutorById(String tutorId) async {
    final doc = await _users.findOne(
      where
          .eq('_id', ObjectId.fromHexString(tutorId))
          .eq('role', 'tutor'),
    );
    if (doc == null) return null;
    return UserModel.fromMap(doc).toPublicMap();
  }

  Future<void> updateProfileImage(String userId, String base64Image) async {
    await _users.updateOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
      modify
          .set('profileImage', base64Image)
          .set('updatedAt', DateTime.now()),
    );
  }

  Future<bool> deleteUser(String userId) async {
    final result = await _users.deleteOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
    );
    return result.nRemoved == 1;
  }

  Future<void> updateTutorDocuments(
    String userId,
    Map<String, String> documents,
  ) async {
    final updates = <String, dynamic>{};
    documents.forEach((key, value) {
      updates['tutorProfile.documents.$key'] = value;
    });
    updates['updatedAt'] = DateTime.now();

    final modifier = ModifierBuilder();
    updates.forEach((key, value) {
      modifier.set(key, value);
    });

    await _users.updateOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
      modifier,
    );
  }
}
