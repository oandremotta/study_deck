import 'package:equatable/equatable.dart';

/// UC161-171: Classroom entity for B2B/Educator features.
///
/// Supports:
/// - UC161: Educator accounts
/// - UC162: Classroom creation
/// - UC163: Invite codes
/// - UC164-165: Student management
/// - UC166-167: Progress tracking

/// User roles in the system.
enum UserRole {
  student,
  educator,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Aluno';
      case UserRole.educator:
        return 'Educador';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}

/// Classroom entity.
class Classroom extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String educatorId;
  final String? inviteCode;
  final DateTime? inviteCodeExpiry;
  final List<String> studentIds;
  final List<String> assignedDeckIds;
  final ClassroomSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Classroom({
    required this.id,
    required this.name,
    this.description,
    required this.educatorId,
    this.inviteCode,
    this.inviteCodeExpiry,
    this.studentIds = const [],
    this.assignedDeckIds = const [],
    this.settings = const ClassroomSettings(),
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if invite code is valid.
  bool get hasValidInviteCode {
    if (inviteCode == null) return false;
    if (inviteCodeExpiry == null) return true;
    return DateTime.now().isBefore(inviteCodeExpiry!);
  }

  /// Student count.
  int get studentCount => studentIds.length;

  /// Assigned deck count.
  int get deckCount => assignedDeckIds.length;

  Classroom copyWith({
    String? id,
    String? name,
    String? description,
    String? educatorId,
    String? inviteCode,
    DateTime? inviteCodeExpiry,
    List<String>? studentIds,
    List<String>? assignedDeckIds,
    ClassroomSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      educatorId: educatorId ?? this.educatorId,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteCodeExpiry: inviteCodeExpiry ?? this.inviteCodeExpiry,
      studentIds: studentIds ?? this.studentIds,
      assignedDeckIds: assignedDeckIds ?? this.assignedDeckIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        educatorId,
        inviteCode,
        inviteCodeExpiry,
        studentIds,
        assignedDeckIds,
        settings,
        createdAt,
        updatedAt,
      ];
}

/// UC171: Classroom settings for restricting student features.
class ClassroomSettings extends Equatable {
  final bool allowStudentDeckCreation;
  final bool allowStudentAiGeneration;
  final bool allowStudentCommunityAccess;
  final bool showLeaderboard;
  final int? dailyStudyGoal;

  const ClassroomSettings({
    this.allowStudentDeckCreation = false,
    this.allowStudentAiGeneration = false,
    this.allowStudentCommunityAccess = true,
    this.showLeaderboard = false,
    this.dailyStudyGoal,
  });

  ClassroomSettings copyWith({
    bool? allowStudentDeckCreation,
    bool? allowStudentAiGeneration,
    bool? allowStudentCommunityAccess,
    bool? showLeaderboard,
    int? dailyStudyGoal,
  }) {
    return ClassroomSettings(
      allowStudentDeckCreation:
          allowStudentDeckCreation ?? this.allowStudentDeckCreation,
      allowStudentAiGeneration:
          allowStudentAiGeneration ?? this.allowStudentAiGeneration,
      allowStudentCommunityAccess:
          allowStudentCommunityAccess ?? this.allowStudentCommunityAccess,
      showLeaderboard: showLeaderboard ?? this.showLeaderboard,
      dailyStudyGoal: dailyStudyGoal ?? this.dailyStudyGoal,
    );
  }

  Map<String, dynamic> toJson() => {
        'allowStudentDeckCreation': allowStudentDeckCreation,
        'allowStudentAiGeneration': allowStudentAiGeneration,
        'allowStudentCommunityAccess': allowStudentCommunityAccess,
        'showLeaderboard': showLeaderboard,
        'dailyStudyGoal': dailyStudyGoal,
      };

  factory ClassroomSettings.fromJson(Map<String, dynamic> json) {
    return ClassroomSettings(
      allowStudentDeckCreation: json['allowStudentDeckCreation'] ?? false,
      allowStudentAiGeneration: json['allowStudentAiGeneration'] ?? false,
      allowStudentCommunityAccess: json['allowStudentCommunityAccess'] ?? true,
      showLeaderboard: json['showLeaderboard'] ?? false,
      dailyStudyGoal: json['dailyStudyGoal'],
    );
  }

  @override
  List<Object?> get props => [
        allowStudentDeckCreation,
        allowStudentAiGeneration,
        allowStudentCommunityAccess,
        showLeaderboard,
        dailyStudyGoal,
      ];
}

/// UC166-167: Student progress in a classroom.
class StudentProgress extends Equatable {
  final String id;
  final String studentId;
  final String classroomId;
  final Map<String, DeckProgress> deckProgress;
  final int totalCardsStudied;
  final int totalStudySessions;
  final int currentStreak;
  final DateTime? lastStudyDate;
  final DateTime joinedAt;

  const StudentProgress({
    required this.id,
    required this.studentId,
    required this.classroomId,
    this.deckProgress = const {},
    this.totalCardsStudied = 0,
    this.totalStudySessions = 0,
    this.currentStreak = 0,
    this.lastStudyDate,
    required this.joinedAt,
  });

  /// Overall completion percentage.
  double get overallCompletion {
    if (deckProgress.isEmpty) return 0;
    final total = deckProgress.values
        .map((p) => p.completionPercentage)
        .reduce((a, b) => a + b);
    return total / deckProgress.length;
  }

  StudentProgress copyWith({
    String? id,
    String? studentId,
    String? classroomId,
    Map<String, DeckProgress>? deckProgress,
    int? totalCardsStudied,
    int? totalStudySessions,
    int? currentStreak,
    DateTime? lastStudyDate,
    DateTime? joinedAt,
  }) {
    return StudentProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classroomId: classroomId ?? this.classroomId,
      deckProgress: deckProgress ?? this.deckProgress,
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      totalStudySessions: totalStudySessions ?? this.totalStudySessions,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        classroomId,
        deckProgress,
        totalCardsStudied,
        totalStudySessions,
        currentStreak,
        lastStudyDate,
        joinedAt,
      ];
}

/// Progress in a specific deck.
class DeckProgress extends Equatable {
  final String deckId;
  final int cardsStudied;
  final int totalCards;
  final int cardsMastered;
  final DateTime? lastStudied;

  const DeckProgress({
    required this.deckId,
    this.cardsStudied = 0,
    this.totalCards = 0,
    this.cardsMastered = 0,
    this.lastStudied,
  });

  double get completionPercentage =>
      totalCards > 0 ? (cardsStudied / totalCards) * 100 : 0;

  double get masteryPercentage =>
      totalCards > 0 ? (cardsMastered / totalCards) * 100 : 0;

  @override
  List<Object?> get props => [
        deckId,
        cardsStudied,
        totalCards,
        cardsMastered,
        lastStudied,
      ];
}

/// UC168-169: B2B license.
class B2bLicense extends Equatable {
  final String id;
  final String organizationId;
  final String organizationName;
  final B2bPlan plan;
  final int maxLicenses;
  final int usedLicenses;
  final List<String> educatorIds;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const B2bLicense({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.plan,
    required this.maxLicenses,
    this.usedLicenses = 0,
    this.educatorIds = const [],
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  int get availableLicenses => maxLicenses - usedLicenses;

  bool get hasAvailableLicenses => availableLicenses > 0;

  @override
  List<Object?> get props => [
        id,
        organizationId,
        organizationName,
        plan,
        maxLicenses,
        usedLicenses,
        educatorIds,
        startDate,
        endDate,
        isActive,
      ];
}

/// B2B subscription plans.
enum B2bPlan {
  starter,    // Up to 30 students
  school,     // Up to 200 students
  district,   // Up to 1000 students
  enterprise; // Unlimited

  String get displayName {
    switch (this) {
      case B2bPlan.starter:
        return 'Starter';
      case B2bPlan.school:
        return 'Escola';
      case B2bPlan.district:
        return 'Distrito';
      case B2bPlan.enterprise:
        return 'Enterprise';
    }
  }

  int get maxStudents {
    switch (this) {
      case B2bPlan.starter:
        return 30;
      case B2bPlan.school:
        return 200;
      case B2bPlan.district:
        return 1000;
      case B2bPlan.enterprise:
        return 999999;
    }
  }

  double get pricePerStudentMonth {
    switch (this) {
      case B2bPlan.starter:
        return 3.0;
      case B2bPlan.school:
        return 2.5;
      case B2bPlan.district:
        return 2.0;
      case B2bPlan.enterprise:
        return 1.5;
    }
  }
}
