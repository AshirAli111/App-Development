import 'package:mongo_dart/mongo_dart.dart';

class StudentProfile {
  final int? age;
  final String? grade;
  final String? address;
  final List<String> selectedCourses;
  final int dailyGoalMinutes;

  StudentProfile({
    this.age,
    this.grade,
    this.address,
    this.selectedCourses = const [],
    this.dailyGoalMinutes = 30,
  });

  Map<String, dynamic> toMap() => {
    'age': age,
    'grade': grade,
    'address': address,
    'selectedCourses': selectedCourses,
    'dailyGoalMinutes': dailyGoalMinutes,
  };

  factory StudentProfile.fromMap(Map<String, dynamic> map) => StudentProfile(
    age: map['age'],
    grade: map['grade'],
    address: map['address'],
    selectedCourses: List<String>.from(map['selectedCourses'] ?? []),
    dailyGoalMinutes: map['dailyGoalMinutes'] ?? 30,
  );
}

class TutorDocuments {
  final String? cnicFront;
  final String? cnicBack;
  final String? teachingCertificate;
  final String? degree;

  TutorDocuments({
    this.cnicFront,
    this.cnicBack,
    this.teachingCertificate,
    this.degree,
  });

  Map<String, dynamic> toMap() => {
    'cnicFront': cnicFront,
    'cnicBack': cnicBack,
    'teachingCertificate': teachingCertificate,
    'degree': degree,
  };

  factory TutorDocuments.fromMap(Map<String, dynamic> map) => TutorDocuments(
    cnicFront: map['cnicFront'],
    cnicBack: map['cnicBack'],
    teachingCertificate: map['teachingCertificate'],
    degree: map['degree'],
  );
}

class TutorProfile {
  final int? experienceYears;
  final String? qualification;
  final List<String> subjects;
  final String? bio;
  final double rating;
  final int totalRatings;
  final int? pricePerHourPKR;
  final bool isApproved;
  final TutorDocuments? documents;

  TutorProfile({
    this.experienceYears,
    this.qualification,
    this.subjects = const [],
    this.bio,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.pricePerHourPKR,
    this.isApproved = true,
    this.documents,
  });

  Map<String, dynamic> toMap() => {
    'experienceYears': experienceYears,
    'qualification': qualification,
    'subjects': subjects,
    'bio': bio,
    'rating': rating,
    'totalRatings': totalRatings,
    'pricePerHourPKR': pricePerHourPKR,
    'isApproved': isApproved,
    'documents': documents?.toMap(),
  };

  factory TutorProfile.fromMap(Map<String, dynamic> map) => TutorProfile(
    experienceYears: map['experienceYears'],
    qualification: map['qualification'],
    subjects: List<String>.from(map['subjects'] ?? []),
    bio: map['bio'],
    rating: (map['rating'] ?? 0.0).toDouble(),
    totalRatings: map['totalRatings'] ?? 0,
    pricePerHourPKR: map['pricePerHourPKR'],
    isApproved: map['isApproved'] ?? false,
    documents: map['documents'] != null
        ? TutorDocuments.fromMap(map['documents'])
        : null,
  );
}

class UserModel {
  final ObjectId? id;
  final String role; // 'student' or 'tutor'
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String? profileImage;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StudentProfile? studentProfile;
  final TutorProfile? tutorProfile;

  UserModel({
    this.id,
    required this.role,
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    this.profileImage,
    this.isActive = true,
    this.isVerified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.studentProfile,
    this.tutorProfile,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'role': role,
    'email': email,
    'password': password,
    'fullName': fullName,
    'phone': phone,
    'profileImage': profileImage,
    'isActive': isActive,
    'isVerified': isVerified,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'studentProfile': studentProfile?.toMap(),
    'tutorProfile': tutorProfile?.toMap(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['_id'],
    role: map['role'],
    email: map['email'],
    password: map['password'],
    fullName: map['fullName'],
    phone: map['phone'],
    profileImage: map['profileImage'],
    isActive: map['isActive'] ?? true,
    isVerified: map['isVerified'] ?? false,
    createdAt: map['createdAt'] is DateTime
        ? map['createdAt']
        : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: map['updatedAt'] is DateTime
        ? map['updatedAt']
        : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    studentProfile: map['studentProfile'] != null
        ? StudentProfile.fromMap(map['studentProfile'])
        : null,
    tutorProfile: map['tutorProfile'] != null
        ? TutorProfile.fromMap(map['tutorProfile'])
        : null,
  );

  /// Returns user map without sensitive fields (password)
  Map<String, dynamic> toPublicMap() {
    final map = toMap();
    map.remove('password');
    if (map['_id'] != null) {
      map['id'] = (map['_id'] as ObjectId).oid;
      map.remove('_id');
    }
    return map;
  }
}
