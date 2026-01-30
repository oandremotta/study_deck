// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserTableTable extends UserTable
    with TableInfo<$UserTableTable, UserTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAnonymousMeta =
      const VerificationMeta('isAnonymous');
  @override
  late final GeneratedColumn<bool> isAnonymous = GeneratedColumn<bool>(
      'is_anonymous', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_anonymous" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, email, displayName, isAnonymous, createdAt, lastSyncAt, remoteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('is_anonymous')) {
      context.handle(
          _isAnonymousMeta,
          isAnonymous.isAcceptableOrUnknown(
              data['is_anonymous']!, _isAnonymousMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      isAnonymous: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_anonymous'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class UserTableData extends DataClass implements Insertable<UserTableData> {
  /// Primary key - UUID for local users, Firebase UID for authenticated.
  final String id;

  /// User's email (null for anonymous users).
  final String? email;

  /// User's display name.
  final String? displayName;

  /// Whether this is a local-only user.
  final bool isAnonymous;

  /// When the user was created.
  final DateTime createdAt;

  /// When data was last synced with cloud.
  final DateTime? lastSyncAt;

  /// Remote user ID if linked to cloud account.
  final String? remoteId;
  const UserTableData(
      {required this.id,
      this.email,
      this.displayName,
      required this.isAnonymous,
      required this.createdAt,
      this.lastSyncAt,
      this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['is_anonymous'] = Variable<bool>(isAnonymous);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      id: Value(id),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      isAnonymous: Value(isAnonymous),
      createdAt: Value(createdAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory UserTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTableData(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String?>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      isAnonymous: serializer.fromJson<bool>(json['isAnonymous']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'isAnonymous': serializer.toJson<bool>(isAnonymous),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  UserTableData copyWith(
          {String? id,
          Value<String?> email = const Value.absent(),
          Value<String?> displayName = const Value.absent(),
          bool? isAnonymous,
          DateTime? createdAt,
          Value<DateTime?> lastSyncAt = const Value.absent(),
          Value<String?> remoteId = const Value.absent()}) =>
      UserTableData(
        id: id ?? this.id,
        email: email.present ? email.value : this.email,
        displayName: displayName.present ? displayName.value : this.displayName,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        createdAt: createdAt ?? this.createdAt,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
      );
  UserTableData copyWithCompanion(UserTableCompanion data) {
    return UserTableData(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      isAnonymous:
          data.isAnonymous.present ? data.isAnonymous.value : this.isAnonymous,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTableData(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, email, displayName, isAnonymous, createdAt, lastSyncAt, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTableData &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.isAnonymous == this.isAnonymous &&
          other.createdAt == this.createdAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.remoteId == this.remoteId);
}

class UserTableCompanion extends UpdateCompanion<UserTableData> {
  final Value<String> id;
  final Value<String?> email;
  final Value<String?> displayName;
  final Value<bool> isAnonymous;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const UserTableCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTableCompanion.insert({
    required String id,
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    required DateTime createdAt,
    this.lastSyncAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<UserTableData> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<bool>? isAnonymous,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (isAnonymous != null) 'is_anonymous': isAnonymous,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? email,
      Value<String?>? displayName,
      Value<bool>? isAnonymous,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastSyncAt,
      Value<String?>? remoteId,
      Value<int>? rowid}) {
    return UserTableCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isAnonymous.present) {
      map['is_anonymous'] = Variable<bool>(isAnonymous.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderTableTable extends FolderTable
    with TableInfo<$FolderTableTable, FolderTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, userId, createdAt, updatedAt, isSynced, remoteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_table';
  @override
  VerificationContext validateIntegrity(Insertable<FolderTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FolderTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
    );
  }

  @override
  $FolderTableTable createAlias(String alias) {
    return $FolderTableTable(attachedDatabase, alias);
  }
}

class FolderTableData extends DataClass implements Insertable<FolderTableData> {
  /// Primary key - UUID.
  final String id;

  /// Folder name.
  final String name;

  /// Owner user ID.
  final String userId;

  /// When the folder was created.
  final DateTime createdAt;

  /// When the folder was last updated.
  final DateTime updatedAt;

  /// Whether this folder has been synced with cloud.
  final bool isSynced;

  /// Remote folder ID if synced.
  final String? remoteId;
  const FolderTableData(
      {required this.id,
      required this.name,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.isSynced,
      this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  FolderTableCompanion toCompanion(bool nullToAbsent) {
    return FolderTableCompanion(
      id: Value(id),
      name: Value(name),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory FolderTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  FolderTableData copyWith(
          {String? id,
          String? name,
          String? userId,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isSynced,
          Value<String?> remoteId = const Value.absent()}) =>
      FolderTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
      );
  FolderTableData copyWithCompanion(FolderTableCompanion data) {
    return FolderTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, userId, createdAt, updatedAt, isSynced, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.remoteId == this.remoteId);
}

class FolderTableCompanion extends UpdateCompanion<FolderTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const FolderTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderTableCompanion.insert({
    required String id,
    required String name,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        userId = Value(userId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FolderTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? userId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<String?>? remoteId,
      Value<int>? rowid}) {
    return FolderTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeckTableTable extends DeckTable
    with TableInfo<$DeckTableTable, DeckTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        userId,
        folderId,
        createdAt,
        updatedAt,
        isSynced,
        remoteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_table';
  @override
  VerificationContext validateIntegrity(Insertable<DeckTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
    );
  }

  @override
  $DeckTableTable createAlias(String alias) {
    return $DeckTableTable(attachedDatabase, alias);
  }
}

class DeckTableData extends DataClass implements Insertable<DeckTableData> {
  /// Primary key - UUID.
  final String id;

  /// Deck name/title.
  final String name;

  /// Optional description.
  final String? description;

  /// Owner user ID.
  final String userId;

  /// Parent folder ID (null = root/no folder).
  final String? folderId;

  /// When the deck was created.
  final DateTime createdAt;

  /// When the deck was last updated.
  final DateTime updatedAt;

  /// Whether this deck has been synced with cloud.
  final bool isSynced;

  /// Remote deck ID if synced.
  final String? remoteId;
  const DeckTableData(
      {required this.id,
      required this.name,
      this.description,
      required this.userId,
      this.folderId,
      required this.createdAt,
      required this.updatedAt,
      required this.isSynced,
      this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  DeckTableCompanion toCompanion(bool nullToAbsent) {
    return DeckTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      userId: Value(userId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory DeckTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      userId: serializer.fromJson<String>(json['userId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'userId': serializer.toJson<String>(userId),
      'folderId': serializer.toJson<String?>(folderId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  DeckTableData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? userId,
          Value<String?> folderId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isSynced,
          Value<String?> remoteId = const Value.absent()}) =>
      DeckTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        userId: userId ?? this.userId,
        folderId: folderId.present ? folderId.value : this.folderId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
      );
  DeckTableData copyWithCompanion(DeckTableCompanion data) {
    return DeckTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      userId: data.userId.present ? data.userId.value : this.userId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('folderId: $folderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, userId, folderId,
      createdAt, updatedAt, isSynced, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.userId == this.userId &&
          other.folderId == this.folderId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.remoteId == this.remoteId);
}

class DeckTableCompanion extends UpdateCompanion<DeckTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> userId;
  final Value<String?> folderId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const DeckTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.userId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String userId,
    this.folderId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        userId = Value(userId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DeckTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? userId,
    Expression<String>? folderId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (userId != null) 'user_id': userId,
      if (folderId != null) 'folder_id': folderId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? userId,
      Value<String?>? folderId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<String?>? remoteId,
      Value<int>? rowid}) {
    return DeckTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('folderId: $folderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTableTable extends CardTable
    with TableInfo<$CardTableTable, CardTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
      'front', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
      'back', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
      'hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaPathMeta =
      const VerificationMeta('mediaPath');
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
      'media_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        front,
        back,
        hint,
        mediaPath,
        mediaType,
        createdAt,
        updatedAt,
        deletedAt,
        isSynced,
        remoteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_table';
  @override
  VerificationContext validateIntegrity(Insertable<CardTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
          _frontMeta, front.isAcceptableOrUnknown(data['front']!, _frontMeta));
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
          _backMeta, back.isAcceptableOrUnknown(data['back']!, _backMeta));
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
          _hintMeta, hint.isAcceptableOrUnknown(data['hint']!, _hintMeta));
    }
    if (data.containsKey('media_path')) {
      context.handle(_mediaPathMeta,
          mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta));
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      front: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front'])!,
      back: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back'])!,
      hint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hint']),
      mediaPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_path']),
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
    );
  }

  @override
  $CardTableTable createAlias(String alias) {
    return $CardTableTable(attachedDatabase, alias);
  }
}

class CardTableData extends DataClass implements Insertable<CardTableData> {
  /// Primary key - UUID.
  final String id;

  /// Parent deck ID.
  final String deckId;

  /// Front side content (question).
  final String front;

  /// Back side content (answer).
  final String back;

  /// Optional hint.
  final String? hint;

  /// Path to attached media file.
  final String? mediaPath;

  /// Type of media ('image', 'audio').
  final String? mediaType;

  /// When the card was created.
  final DateTime createdAt;

  /// When the card was last updated.
  final DateTime updatedAt;

  /// When the card was soft-deleted (null = not deleted).
  final DateTime? deletedAt;

  /// Whether this card has been synced with cloud.
  final bool isSynced;

  /// Remote card ID if synced.
  final String? remoteId;
  const CardTableData(
      {required this.id,
      required this.deckId,
      required this.front,
      required this.back,
      this.hint,
      this.mediaPath,
      this.mediaType,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.isSynced,
      this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    if (!nullToAbsent || mediaPath != null) {
      map['media_path'] = Variable<String>(mediaPath);
    }
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<String>(mediaType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  CardTableCompanion toCompanion(bool nullToAbsent) {
    return CardTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      mediaPath: mediaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaPath),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory CardTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      hint: serializer.fromJson<String?>(json['hint']),
      mediaPath: serializer.fromJson<String?>(json['mediaPath']),
      mediaType: serializer.fromJson<String?>(json['mediaType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'hint': serializer.toJson<String?>(hint),
      'mediaPath': serializer.toJson<String?>(mediaPath),
      'mediaType': serializer.toJson<String?>(mediaType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  CardTableData copyWith(
          {String? id,
          String? deckId,
          String? front,
          String? back,
          Value<String?> hint = const Value.absent(),
          Value<String?> mediaPath = const Value.absent(),
          Value<String?> mediaType = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? isSynced,
          Value<String?> remoteId = const Value.absent()}) =>
      CardTableData(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        front: front ?? this.front,
        back: back ?? this.back,
        hint: hint.present ? hint.value : this.hint,
        mediaPath: mediaPath.present ? mediaPath.value : this.mediaPath,
        mediaType: mediaType.present ? mediaType.value : this.mediaType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isSynced: isSynced ?? this.isSynced,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
      );
  CardTableData copyWithCompanion(CardTableCompanion data) {
    return CardTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      hint: data.hint.present ? data.hint.value : this.hint,
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deckId, front, back, hint, mediaPath,
      mediaType, createdAt, updatedAt, deletedAt, isSynced, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.hint == this.hint &&
          other.mediaPath == this.mediaPath &&
          other.mediaType == this.mediaType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced &&
          other.remoteId == this.remoteId);
}

class CardTableCompanion extends UpdateCompanion<CardTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> hint;
  final Value<String?> mediaPath;
  final Value<String?> mediaType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const CardTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.hint = const Value.absent(),
    this.mediaPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTableCompanion.insert({
    required String id,
    required String deckId,
    required String front,
    required String back,
    this.hint = const Value.absent(),
    this.mediaPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckId = Value(deckId),
        front = Value(front),
        back = Value(back),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CardTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? hint,
    Expression<String>? mediaPath,
    Expression<String>? mediaType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (hint != null) 'hint': hint,
      if (mediaPath != null) 'media_path': mediaPath,
      if (mediaType != null) 'media_type': mediaType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deckId,
      Value<String>? front,
      Value<String>? back,
      Value<String?>? hint,
      Value<String?>? mediaPath,
      Value<String?>? mediaType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? isSynced,
      Value<String?>? remoteId,
      Value<int>? rowid}) {
    return CardTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagTableTable extends TagTable
    with TableInfo<$TagTableTable, TagTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, color, userId, createdAt, isSynced, remoteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_table';
  @override
  VerificationContext validateIntegrity(Insertable<TagTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
    );
  }

  @override
  $TagTableTable createAlias(String alias) {
    return $TagTableTable(attachedDatabase, alias);
  }
}

class TagTableData extends DataClass implements Insertable<TagTableData> {
  /// Primary key - UUID.
  final String id;

  /// Tag name.
  final String name;

  /// Tag color in hex format.
  final String color;

  /// Owner user ID.
  final String userId;

  /// When the tag was created.
  final DateTime createdAt;

  /// Whether this tag has been synced with cloud.
  final bool isSynced;

  /// Remote tag ID if synced.
  final String? remoteId;
  const TagTableData(
      {required this.id,
      required this.name,
      required this.color,
      required this.userId,
      required this.createdAt,
      required this.isSynced,
      this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  TagTableCompanion toCompanion(bool nullToAbsent) {
    return TagTableCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      userId: Value(userId),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory TagTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  TagTableData copyWith(
          {String? id,
          String? name,
          String? color,
          String? userId,
          DateTime? createdAt,
          bool? isSynced,
          Value<String?> remoteId = const Value.absent()}) =>
      TagTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
      );
  TagTableData copyWithCompanion(TagTableCompanion data) {
    return TagTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, userId, createdAt, isSynced, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.remoteId == this.remoteId);
}

class TagTableCompanion extends UpdateCompanion<TagTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const TagTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagTableCompanion.insert({
    required String id,
    required String name,
    required String color,
    required String userId,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        color = Value(color),
        userId = Value(userId),
        createdAt = Value(createdAt);
  static Insertable<TagTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? color,
      Value<String>? userId,
      Value<DateTime>? createdAt,
      Value<bool>? isSynced,
      Value<String?>? remoteId,
      Value<int>? rowid}) {
    return TagTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTagTableTable extends CardTagTable
    with TableInfo<$CardTagTableTable, CardTagTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTagTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cardId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_tag_table';
  @override
  VerificationContext validateIntegrity(Insertable<CardTagTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, tagId};
  @override
  CardTagTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTagTableData(
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $CardTagTableTable createAlias(String alias) {
    return $CardTagTableTable(attachedDatabase, alias);
  }
}

class CardTagTableData extends DataClass
    implements Insertable<CardTagTableData> {
  /// Card ID.
  final String cardId;

  /// Tag ID.
  final String tagId;
  const CardTagTableData({required this.cardId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  CardTagTableCompanion toCompanion(bool nullToAbsent) {
    return CardTagTableCompanion(
      cardId: Value(cardId),
      tagId: Value(tagId),
    );
  }

  factory CardTagTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTagTableData(
      cardId: serializer.fromJson<String>(json['cardId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  CardTagTableData copyWith({String? cardId, String? tagId}) =>
      CardTagTableData(
        cardId: cardId ?? this.cardId,
        tagId: tagId ?? this.tagId,
      );
  CardTagTableData copyWithCompanion(CardTagTableCompanion data) {
    return CardTagTableData(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTagTableData(')
          ..write('cardId: $cardId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTagTableData &&
          other.cardId == this.cardId &&
          other.tagId == this.tagId);
}

class CardTagTableCompanion extends UpdateCompanion<CardTagTableData> {
  final Value<String> cardId;
  final Value<String> tagId;
  final Value<int> rowid;
  const CardTagTableCompanion({
    this.cardId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTagTableCompanion.insert({
    required String cardId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : cardId = Value(cardId),
        tagId = Value(tagId);
  static Insertable<CardTagTableData> custom({
    Expression<String>? cardId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTagTableCompanion copyWith(
      {Value<String>? cardId, Value<String>? tagId, Value<int>? rowid}) {
    return CardTagTableCompanion(
      cardId: cardId ?? this.cardId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTagTableCompanion(')
          ..write('cardId: $cardId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionTableTable extends StudySessionTable
    with TableInfo<$StudySessionTableTable, StudySessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pausedAtMeta =
      const VerificationMeta('pausedAt');
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
      'paused_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _totalCardsMeta =
      const VerificationMeta('totalCards');
  @override
  late final GeneratedColumn<int> totalCards = GeneratedColumn<int>(
      'total_cards', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reviewedCardsMeta =
      const VerificationMeta('reviewedCards');
  @override
  late final GeneratedColumn<int> reviewedCards = GeneratedColumn<int>(
      'reviewed_cards', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _correctCountMeta =
      const VerificationMeta('correctCount');
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
      'correct_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _almostCountMeta =
      const VerificationMeta('almostCount');
  @override
  late final GeneratedColumn<int> almostCount = GeneratedColumn<int>(
      'almost_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wrongCountMeta =
      const VerificationMeta('wrongCount');
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
      'wrong_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _xpEarnedMeta =
      const VerificationMeta('xpEarned');
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
      'xp_earned', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalTimeSecondsMeta =
      const VerificationMeta('totalTimeSeconds');
  @override
  late final GeneratedColumn<int> totalTimeSeconds = GeneratedColumn<int>(
      'total_time_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        userId,
        mode,
        status,
        startedAt,
        pausedAt,
        completedAt,
        totalCards,
        reviewedCards,
        correctCount,
        almostCount,
        wrongCount,
        xpEarned,
        totalTimeSeconds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<StudySessionTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('paused_at')) {
      context.handle(_pausedAtMeta,
          pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('total_cards')) {
      context.handle(
          _totalCardsMeta,
          totalCards.isAcceptableOrUnknown(
              data['total_cards']!, _totalCardsMeta));
    } else if (isInserting) {
      context.missing(_totalCardsMeta);
    }
    if (data.containsKey('reviewed_cards')) {
      context.handle(
          _reviewedCardsMeta,
          reviewedCards.isAcceptableOrUnknown(
              data['reviewed_cards']!, _reviewedCardsMeta));
    }
    if (data.containsKey('correct_count')) {
      context.handle(
          _correctCountMeta,
          correctCount.isAcceptableOrUnknown(
              data['correct_count']!, _correctCountMeta));
    }
    if (data.containsKey('almost_count')) {
      context.handle(
          _almostCountMeta,
          almostCount.isAcceptableOrUnknown(
              data['almost_count']!, _almostCountMeta));
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
          _wrongCountMeta,
          wrongCount.isAcceptableOrUnknown(
              data['wrong_count']!, _wrongCountMeta));
    }
    if (data.containsKey('xp_earned')) {
      context.handle(_xpEarnedMeta,
          xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta));
    }
    if (data.containsKey('total_time_seconds')) {
      context.handle(
          _totalTimeSecondsMeta,
          totalTimeSeconds.isAcceptableOrUnknown(
              data['total_time_seconds']!, _totalTimeSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySessionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySessionTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      pausedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paused_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      totalCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cards'])!,
      reviewedCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reviewed_cards'])!,
      correctCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_count'])!,
      almostCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}almost_count'])!,
      wrongCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wrong_count'])!,
      xpEarned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}xp_earned'])!,
      totalTimeSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_time_seconds'])!,
    );
  }

  @override
  $StudySessionTableTable createAlias(String alias) {
    return $StudySessionTableTable(attachedDatabase, alias);
  }
}

class StudySessionTableData extends DataClass
    implements Insertable<StudySessionTableData> {
  /// Unique identifier.
  final String id;

  /// Deck being studied (null for cross-deck study).
  final String? deckId;

  /// User who owns this session.
  final String userId;

  /// Study mode (studyNow, reviewsToday, etc.).
  final String mode;

  /// Session status (inProgress, paused, completed).
  final String status;

  /// When the session started.
  final DateTime startedAt;

  /// When the session was paused (if applicable).
  final DateTime? pausedAt;

  /// When the session was completed (if applicable).
  final DateTime? completedAt;

  /// Total cards in the session queue.
  final int totalCards;

  /// Number of cards reviewed.
  final int reviewedCards;

  /// Number of correct answers.
  final int correctCount;

  /// Number of "almost" answers.
  final int almostCount;

  /// Number of wrong answers.
  final int wrongCount;

  /// XP earned in this session.
  final int xpEarned;

  /// Total time spent (in seconds).
  final int totalTimeSeconds;
  const StudySessionTableData(
      {required this.id,
      this.deckId,
      required this.userId,
      required this.mode,
      required this.status,
      required this.startedAt,
      this.pausedAt,
      this.completedAt,
      required this.totalCards,
      required this.reviewedCards,
      required this.correctCount,
      required this.almostCount,
      required this.wrongCount,
      required this.xpEarned,
      required this.totalTimeSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || deckId != null) {
      map['deck_id'] = Variable<String>(deckId);
    }
    map['user_id'] = Variable<String>(userId);
    map['mode'] = Variable<String>(mode);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['total_cards'] = Variable<int>(totalCards);
    map['reviewed_cards'] = Variable<int>(reviewedCards);
    map['correct_count'] = Variable<int>(correctCount);
    map['almost_count'] = Variable<int>(almostCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['total_time_seconds'] = Variable<int>(totalTimeSeconds);
    return map;
  }

  StudySessionTableCompanion toCompanion(bool nullToAbsent) {
    return StudySessionTableCompanion(
      id: Value(id),
      deckId:
          deckId == null && nullToAbsent ? const Value.absent() : Value(deckId),
      userId: Value(userId),
      mode: Value(mode),
      status: Value(status),
      startedAt: Value(startedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      totalCards: Value(totalCards),
      reviewedCards: Value(reviewedCards),
      correctCount: Value(correctCount),
      almostCount: Value(almostCount),
      wrongCount: Value(wrongCount),
      xpEarned: Value(xpEarned),
      totalTimeSeconds: Value(totalTimeSeconds),
    );
  }

  factory StudySessionTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySessionTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String?>(json['deckId']),
      userId: serializer.fromJson<String>(json['userId']),
      mode: serializer.fromJson<String>(json['mode']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      totalCards: serializer.fromJson<int>(json['totalCards']),
      reviewedCards: serializer.fromJson<int>(json['reviewedCards']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      almostCount: serializer.fromJson<int>(json['almostCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      totalTimeSeconds: serializer.fromJson<int>(json['totalTimeSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String?>(deckId),
      'userId': serializer.toJson<String>(userId),
      'mode': serializer.toJson<String>(mode),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'totalCards': serializer.toJson<int>(totalCards),
      'reviewedCards': serializer.toJson<int>(reviewedCards),
      'correctCount': serializer.toJson<int>(correctCount),
      'almostCount': serializer.toJson<int>(almostCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'totalTimeSeconds': serializer.toJson<int>(totalTimeSeconds),
    };
  }

  StudySessionTableData copyWith(
          {String? id,
          Value<String?> deckId = const Value.absent(),
          String? userId,
          String? mode,
          String? status,
          DateTime? startedAt,
          Value<DateTime?> pausedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          int? totalCards,
          int? reviewedCards,
          int? correctCount,
          int? almostCount,
          int? wrongCount,
          int? xpEarned,
          int? totalTimeSeconds}) =>
      StudySessionTableData(
        id: id ?? this.id,
        deckId: deckId.present ? deckId.value : this.deckId,
        userId: userId ?? this.userId,
        mode: mode ?? this.mode,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        totalCards: totalCards ?? this.totalCards,
        reviewedCards: reviewedCards ?? this.reviewedCards,
        correctCount: correctCount ?? this.correctCount,
        almostCount: almostCount ?? this.almostCount,
        wrongCount: wrongCount ?? this.wrongCount,
        xpEarned: xpEarned ?? this.xpEarned,
        totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      );
  StudySessionTableData copyWithCompanion(StudySessionTableCompanion data) {
    return StudySessionTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      userId: data.userId.present ? data.userId.value : this.userId,
      mode: data.mode.present ? data.mode.value : this.mode,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      totalCards:
          data.totalCards.present ? data.totalCards.value : this.totalCards,
      reviewedCards: data.reviewedCards.present
          ? data.reviewedCards.value
          : this.reviewedCards,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      almostCount:
          data.almostCount.present ? data.almostCount.value : this.almostCount,
      wrongCount:
          data.wrongCount.present ? data.wrongCount.value : this.wrongCount,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      totalTimeSeconds: data.totalTimeSeconds.present
          ? data.totalTimeSeconds.value
          : this.totalTimeSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('userId: $userId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalCards: $totalCards, ')
          ..write('reviewedCards: $reviewedCards, ')
          ..write('correctCount: $correctCount, ')
          ..write('almostCount: $almostCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('totalTimeSeconds: $totalTimeSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deckId,
      userId,
      mode,
      status,
      startedAt,
      pausedAt,
      completedAt,
      totalCards,
      reviewedCards,
      correctCount,
      almostCount,
      wrongCount,
      xpEarned,
      totalTimeSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySessionTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.userId == this.userId &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.pausedAt == this.pausedAt &&
          other.completedAt == this.completedAt &&
          other.totalCards == this.totalCards &&
          other.reviewedCards == this.reviewedCards &&
          other.correctCount == this.correctCount &&
          other.almostCount == this.almostCount &&
          other.wrongCount == this.wrongCount &&
          other.xpEarned == this.xpEarned &&
          other.totalTimeSeconds == this.totalTimeSeconds);
}

class StudySessionTableCompanion
    extends UpdateCompanion<StudySessionTableData> {
  final Value<String> id;
  final Value<String?> deckId;
  final Value<String> userId;
  final Value<String> mode;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> completedAt;
  final Value<int> totalCards;
  final Value<int> reviewedCards;
  final Value<int> correctCount;
  final Value<int> almostCount;
  final Value<int> wrongCount;
  final Value<int> xpEarned;
  final Value<int> totalTimeSeconds;
  final Value<int> rowid;
  const StudySessionTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.userId = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.totalCards = const Value.absent(),
    this.reviewedCards = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.almostCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionTableCompanion.insert({
    required String id,
    this.deckId = const Value.absent(),
    required String userId,
    required String mode,
    required String status,
    required DateTime startedAt,
    this.pausedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int totalCards,
    this.reviewedCards = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.almostCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        mode = Value(mode),
        status = Value(status),
        startedAt = Value(startedAt),
        totalCards = Value(totalCards);
  static Insertable<StudySessionTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? userId,
    Expression<String>? mode,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? totalCards,
    Expression<int>? reviewedCards,
    Expression<int>? correctCount,
    Expression<int>? almostCount,
    Expression<int>? wrongCount,
    Expression<int>? xpEarned,
    Expression<int>? totalTimeSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (userId != null) 'user_id': userId,
      if (mode != null) 'mode': mode,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (totalCards != null) 'total_cards': totalCards,
      if (reviewedCards != null) 'reviewed_cards': reviewedCards,
      if (correctCount != null) 'correct_count': correctCount,
      if (almostCount != null) 'almost_count': almostCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (totalTimeSeconds != null) 'total_time_seconds': totalTimeSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? deckId,
      Value<String>? userId,
      Value<String>? mode,
      Value<String>? status,
      Value<DateTime>? startedAt,
      Value<DateTime?>? pausedAt,
      Value<DateTime?>? completedAt,
      Value<int>? totalCards,
      Value<int>? reviewedCards,
      Value<int>? correctCount,
      Value<int>? almostCount,
      Value<int>? wrongCount,
      Value<int>? xpEarned,
      Value<int>? totalTimeSeconds,
      Value<int>? rowid}) {
    return StudySessionTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      totalCards: totalCards ?? this.totalCards,
      reviewedCards: reviewedCards ?? this.reviewedCards,
      correctCount: correctCount ?? this.correctCount,
      almostCount: almostCount ?? this.almostCount,
      wrongCount: wrongCount ?? this.wrongCount,
      xpEarned: xpEarned ?? this.xpEarned,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (totalCards.present) {
      map['total_cards'] = Variable<int>(totalCards.value);
    }
    if (reviewedCards.present) {
      map['reviewed_cards'] = Variable<int>(reviewedCards.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (almostCount.present) {
      map['almost_count'] = Variable<int>(almostCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (totalTimeSeconds.present) {
      map['total_time_seconds'] = Variable<int>(totalTimeSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('userId: $userId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalCards: $totalCards, ')
          ..write('reviewedCards: $reviewedCards, ')
          ..write('correctCount: $correctCount, ')
          ..write('almostCount: $almostCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardSrsTableTable extends CardSrsTable
    with TableInfo<$CardSrsTableTable, CardSrsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardSrsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _easeFactorMeta =
      const VerificationMeta('easeFactor');
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
      'ease_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _intervalDaysMeta =
      const VerificationMeta('intervalDays');
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
      'interval_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReviewedAtMeta =
      const VerificationMeta('lastReviewedAt');
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>('last_reviewed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextReviewAtMeta =
      const VerificationMeta('nextReviewAt');
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
      'next_review_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _consecutiveCorrectMeta =
      const VerificationMeta('consecutiveCorrect');
  @override
  late final GeneratedColumn<int> consecutiveCorrect = GeneratedColumn<int>(
      'consecutive_correct', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalReviewsMeta =
      const VerificationMeta('totalReviews');
  @override
  late final GeneratedColumn<int> totalReviews = GeneratedColumn<int>(
      'total_reviews', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalCorrectMeta =
      const VerificationMeta('totalCorrect');
  @override
  late final GeneratedColumn<int> totalCorrect = GeneratedColumn<int>(
      'total_correct', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        cardId,
        deckId,
        userId,
        state,
        repetitions,
        easeFactor,
        intervalDays,
        lastReviewedAt,
        nextReviewAt,
        consecutiveCorrect,
        totalReviews,
        totalCorrect
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_srs';
  @override
  VerificationContext validateIntegrity(Insertable<CardSrsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
          _easeFactorMeta,
          easeFactor.isAcceptableOrUnknown(
              data['ease_factor']!, _easeFactorMeta));
    }
    if (data.containsKey('interval_days')) {
      context.handle(
          _intervalDaysMeta,
          intervalDays.isAcceptableOrUnknown(
              data['interval_days']!, _intervalDaysMeta));
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
          _lastReviewedAtMeta,
          lastReviewedAt.isAcceptableOrUnknown(
              data['last_reviewed_at']!, _lastReviewedAtMeta));
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
          _nextReviewAtMeta,
          nextReviewAt.isAcceptableOrUnknown(
              data['next_review_at']!, _nextReviewAtMeta));
    }
    if (data.containsKey('consecutive_correct')) {
      context.handle(
          _consecutiveCorrectMeta,
          consecutiveCorrect.isAcceptableOrUnknown(
              data['consecutive_correct']!, _consecutiveCorrectMeta));
    }
    if (data.containsKey('total_reviews')) {
      context.handle(
          _totalReviewsMeta,
          totalReviews.isAcceptableOrUnknown(
              data['total_reviews']!, _totalReviewsMeta));
    }
    if (data.containsKey('total_correct')) {
      context.handle(
          _totalCorrectMeta,
          totalCorrect.isAcceptableOrUnknown(
              data['total_correct']!, _totalCorrectMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, userId};
  @override
  CardSrsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardSrsTableData(
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      easeFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease_factor'])!,
      intervalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_days'])!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed_at']),
      nextReviewAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_at']),
      consecutiveCorrect: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}consecutive_correct'])!,
      totalReviews: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_reviews'])!,
      totalCorrect: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_correct'])!,
    );
  }

  @override
  $CardSrsTableTable createAlias(String alias) {
    return $CardSrsTableTable(attachedDatabase, alias);
  }
}

class CardSrsTableData extends DataClass
    implements Insertable<CardSrsTableData> {
  /// Card ID (foreign key to cards table).
  final String cardId;

  /// Deck ID for quick filtering.
  final String deckId;

  /// User who owns this SRS data.
  final String userId;

  /// Learning state (newCard, learning, review).
  final String state;

  /// Number of successful repetitions.
  final int repetitions;

  /// Ease factor (SM-2 algorithm).
  final double easeFactor;

  /// Current interval in days.
  final int intervalDays;

  /// When the card was last reviewed.
  final DateTime? lastReviewedAt;

  /// When the card is due for next review.
  final DateTime? nextReviewAt;

  /// Consecutive correct answers.
  final int consecutiveCorrect;

  /// Total number of reviews.
  final int totalReviews;

  /// Total correct answers.
  final int totalCorrect;
  const CardSrsTableData(
      {required this.cardId,
      required this.deckId,
      required this.userId,
      required this.state,
      required this.repetitions,
      required this.easeFactor,
      required this.intervalDays,
      this.lastReviewedAt,
      this.nextReviewAt,
      required this.consecutiveCorrect,
      required this.totalReviews,
      required this.totalCorrect});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['deck_id'] = Variable<String>(deckId);
    map['user_id'] = Variable<String>(userId);
    map['state'] = Variable<String>(state);
    map['repetitions'] = Variable<int>(repetitions);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    map['consecutive_correct'] = Variable<int>(consecutiveCorrect);
    map['total_reviews'] = Variable<int>(totalReviews);
    map['total_correct'] = Variable<int>(totalCorrect);
    return map;
  }

  CardSrsTableCompanion toCompanion(bool nullToAbsent) {
    return CardSrsTableCompanion(
      cardId: Value(cardId),
      deckId: Value(deckId),
      userId: Value(userId),
      state: Value(state),
      repetitions: Value(repetitions),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      consecutiveCorrect: Value(consecutiveCorrect),
      totalReviews: Value(totalReviews),
      totalCorrect: Value(totalCorrect),
    );
  }

  factory CardSrsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardSrsTableData(
      cardId: serializer.fromJson<String>(json['cardId']),
      deckId: serializer.fromJson<String>(json['deckId']),
      userId: serializer.fromJson<String>(json['userId']),
      state: serializer.fromJson<String>(json['state']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      consecutiveCorrect: serializer.fromJson<int>(json['consecutiveCorrect']),
      totalReviews: serializer.fromJson<int>(json['totalReviews']),
      totalCorrect: serializer.fromJson<int>(json['totalCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'deckId': serializer.toJson<String>(deckId),
      'userId': serializer.toJson<String>(userId),
      'state': serializer.toJson<String>(state),
      'repetitions': serializer.toJson<int>(repetitions),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'consecutiveCorrect': serializer.toJson<int>(consecutiveCorrect),
      'totalReviews': serializer.toJson<int>(totalReviews),
      'totalCorrect': serializer.toJson<int>(totalCorrect),
    };
  }

  CardSrsTableData copyWith(
          {String? cardId,
          String? deckId,
          String? userId,
          String? state,
          int? repetitions,
          double? easeFactor,
          int? intervalDays,
          Value<DateTime?> lastReviewedAt = const Value.absent(),
          Value<DateTime?> nextReviewAt = const Value.absent(),
          int? consecutiveCorrect,
          int? totalReviews,
          int? totalCorrect}) =>
      CardSrsTableData(
        cardId: cardId ?? this.cardId,
        deckId: deckId ?? this.deckId,
        userId: userId ?? this.userId,
        state: state ?? this.state,
        repetitions: repetitions ?? this.repetitions,
        easeFactor: easeFactor ?? this.easeFactor,
        intervalDays: intervalDays ?? this.intervalDays,
        lastReviewedAt:
            lastReviewedAt.present ? lastReviewedAt.value : this.lastReviewedAt,
        nextReviewAt:
            nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
        consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
        totalReviews: totalReviews ?? this.totalReviews,
        totalCorrect: totalCorrect ?? this.totalCorrect,
      );
  CardSrsTableData copyWithCompanion(CardSrsTableCompanion data) {
    return CardSrsTableData(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      userId: data.userId.present ? data.userId.value : this.userId,
      state: data.state.present ? data.state.value : this.state,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      consecutiveCorrect: data.consecutiveCorrect.present
          ? data.consecutiveCorrect.value
          : this.consecutiveCorrect,
      totalReviews: data.totalReviews.present
          ? data.totalReviews.value
          : this.totalReviews,
      totalCorrect: data.totalCorrect.present
          ? data.totalCorrect.value
          : this.totalCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardSrsTableData(')
          ..write('cardId: $cardId, ')
          ..write('deckId: $deckId, ')
          ..write('userId: $userId, ')
          ..write('state: $state, ')
          ..write('repetitions: $repetitions, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('consecutiveCorrect: $consecutiveCorrect, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('totalCorrect: $totalCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      cardId,
      deckId,
      userId,
      state,
      repetitions,
      easeFactor,
      intervalDays,
      lastReviewedAt,
      nextReviewAt,
      consecutiveCorrect,
      totalReviews,
      totalCorrect);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardSrsTableData &&
          other.cardId == this.cardId &&
          other.deckId == this.deckId &&
          other.userId == this.userId &&
          other.state == this.state &&
          other.repetitions == this.repetitions &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.nextReviewAt == this.nextReviewAt &&
          other.consecutiveCorrect == this.consecutiveCorrect &&
          other.totalReviews == this.totalReviews &&
          other.totalCorrect == this.totalCorrect);
}

class CardSrsTableCompanion extends UpdateCompanion<CardSrsTableData> {
  final Value<String> cardId;
  final Value<String> deckId;
  final Value<String> userId;
  final Value<String> state;
  final Value<int> repetitions;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> nextReviewAt;
  final Value<int> consecutiveCorrect;
  final Value<int> totalReviews;
  final Value<int> totalCorrect;
  final Value<int> rowid;
  const CardSrsTableCompanion({
    this.cardId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.userId = const Value.absent(),
    this.state = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.consecutiveCorrect = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardSrsTableCompanion.insert({
    required String cardId,
    required String deckId,
    required String userId,
    required String state,
    this.repetitions = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.consecutiveCorrect = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : cardId = Value(cardId),
        deckId = Value(deckId),
        userId = Value(userId),
        state = Value(state);
  static Insertable<CardSrsTableData> custom({
    Expression<String>? cardId,
    Expression<String>? deckId,
    Expression<String>? userId,
    Expression<String>? state,
    Expression<int>? repetitions,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? nextReviewAt,
    Expression<int>? consecutiveCorrect,
    Expression<int>? totalReviews,
    Expression<int>? totalCorrect,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (deckId != null) 'deck_id': deckId,
      if (userId != null) 'user_id': userId,
      if (state != null) 'state': state,
      if (repetitions != null) 'repetitions': repetitions,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (consecutiveCorrect != null) 'consecutive_correct': consecutiveCorrect,
      if (totalReviews != null) 'total_reviews': totalReviews,
      if (totalCorrect != null) 'total_correct': totalCorrect,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardSrsTableCompanion copyWith(
      {Value<String>? cardId,
      Value<String>? deckId,
      Value<String>? userId,
      Value<String>? state,
      Value<int>? repetitions,
      Value<double>? easeFactor,
      Value<int>? intervalDays,
      Value<DateTime?>? lastReviewedAt,
      Value<DateTime?>? nextReviewAt,
      Value<int>? consecutiveCorrect,
      Value<int>? totalReviews,
      Value<int>? totalCorrect,
      Value<int>? rowid}) {
    return CardSrsTableCompanion(
      cardId: cardId ?? this.cardId,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      state: state ?? this.state,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      totalReviews: totalReviews ?? this.totalReviews,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (consecutiveCorrect.present) {
      map['consecutive_correct'] = Variable<int>(consecutiveCorrect.value);
    }
    if (totalReviews.present) {
      map['total_reviews'] = Variable<int>(totalReviews.value);
    }
    if (totalCorrect.present) {
      map['total_correct'] = Variable<int>(totalCorrect.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardSrsTableCompanion(')
          ..write('cardId: $cardId, ')
          ..write('deckId: $deckId, ')
          ..write('userId: $userId, ')
          ..write('state: $state, ')
          ..write('repetitions: $repetitions, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('consecutiveCorrect: $consecutiveCorrect, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardReviewTableTable extends CardReviewTable
    with TableInfo<$CardReviewTableTable, CardReviewTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardReviewTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
      'reviewed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _responseTimeMsMeta =
      const VerificationMeta('responseTimeMs');
  @override
  late final GeneratedColumn<int> responseTimeMs = GeneratedColumn<int>(
      'response_time_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, cardId, sessionId, userId, result, reviewedAt, responseTimeMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_reviews';
  @override
  VerificationContext validateIntegrity(
      Insertable<CardReviewTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
          _responseTimeMsMeta,
          responseTimeMs.isAcceptableOrUnknown(
              data['response_time_ms']!, _responseTimeMsMeta));
    } else if (isInserting) {
      context.missing(_responseTimeMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardReviewTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardReviewTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result'])!,
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reviewed_at'])!,
      responseTimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}response_time_ms'])!,
    );
  }

  @override
  $CardReviewTableTable createAlias(String alias) {
    return $CardReviewTableTable(attachedDatabase, alias);
  }
}

class CardReviewTableData extends DataClass
    implements Insertable<CardReviewTableData> {
  /// Unique identifier.
  final String id;

  /// Card that was reviewed.
  final String cardId;

  /// Session in which the review occurred.
  final String sessionId;

  /// User who performed the review.
  final String userId;

  /// Result (wrong, almost, correct).
  final String result;

  /// When the review occurred.
  final DateTime reviewedAt;

  /// How long the user took to respond (in milliseconds).
  final int responseTimeMs;
  const CardReviewTableData(
      {required this.id,
      required this.cardId,
      required this.sessionId,
      required this.userId,
      required this.result,
      required this.reviewedAt,
      required this.responseTimeMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['result'] = Variable<String>(result);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['response_time_ms'] = Variable<int>(responseTimeMs);
    return map;
  }

  CardReviewTableCompanion toCompanion(bool nullToAbsent) {
    return CardReviewTableCompanion(
      id: Value(id),
      cardId: Value(cardId),
      sessionId: Value(sessionId),
      userId: Value(userId),
      result: Value(result),
      reviewedAt: Value(reviewedAt),
      responseTimeMs: Value(responseTimeMs),
    );
  }

  factory CardReviewTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardReviewTableData(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      result: serializer.fromJson<String>(json['result']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      responseTimeMs: serializer.fromJson<int>(json['responseTimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'result': serializer.toJson<String>(result),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'responseTimeMs': serializer.toJson<int>(responseTimeMs),
    };
  }

  CardReviewTableData copyWith(
          {String? id,
          String? cardId,
          String? sessionId,
          String? userId,
          String? result,
          DateTime? reviewedAt,
          int? responseTimeMs}) =>
      CardReviewTableData(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        sessionId: sessionId ?? this.sessionId,
        userId: userId ?? this.userId,
        result: result ?? this.result,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      );
  CardReviewTableData copyWithCompanion(CardReviewTableCompanion data) {
    return CardReviewTableData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      result: data.result.present ? data.result.value : this.result,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardReviewTableData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('result: $result, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('responseTimeMs: $responseTimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, cardId, sessionId, userId, result, reviewedAt, responseTimeMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardReviewTableData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.result == this.result &&
          other.reviewedAt == this.reviewedAt &&
          other.responseTimeMs == this.responseTimeMs);
}

class CardReviewTableCompanion extends UpdateCompanion<CardReviewTableData> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<String> result;
  final Value<DateTime> reviewedAt;
  final Value<int> responseTimeMs;
  final Value<int> rowid;
  const CardReviewTableCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.result = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardReviewTableCompanion.insert({
    required String id,
    required String cardId,
    required String sessionId,
    required String userId,
    required String result,
    required DateTime reviewedAt,
    required int responseTimeMs,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cardId = Value(cardId),
        sessionId = Value(sessionId),
        userId = Value(userId),
        result = Value(result),
        reviewedAt = Value(reviewedAt),
        responseTimeMs = Value(responseTimeMs);
  static Insertable<CardReviewTableData> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<String>? result,
    Expression<DateTime>? reviewedAt,
    Expression<int>? responseTimeMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (result != null) 'result': result,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardReviewTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? cardId,
      Value<String>? sessionId,
      Value<String>? userId,
      Value<String>? result,
      Value<DateTime>? reviewedAt,
      Value<int>? responseTimeMs,
      Value<int>? rowid}) {
    return CardReviewTableCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      result: result ?? this.result,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<int>(responseTimeMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardReviewTableCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('result: $result, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTableTable extends UserStatsTable
    with TableInfo<$UserStatsTableTable, UserStatsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalXpMeta =
      const VerificationMeta('totalXp');
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
      'total_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _longestStreakMeta =
      const VerificationMeta('longestStreak');
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
      'longest_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastStudyDateMeta =
      const VerificationMeta('lastStudyDate');
  @override
  late final GeneratedColumn<DateTime> lastStudyDate =
      GeneratedColumn<DateTime>('last_study_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dailyGoalCardsMeta =
      const VerificationMeta('dailyGoalCards');
  @override
  late final GeneratedColumn<int> dailyGoalCards = GeneratedColumn<int>(
      'daily_goal_cards', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _dailyGoalMinutesMeta =
      const VerificationMeta('dailyGoalMinutes');
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
      'daily_goal_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _todayCardsMeta =
      const VerificationMeta('todayCards');
  @override
  late final GeneratedColumn<int> todayCards = GeneratedColumn<int>(
      'today_cards', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _todayMinutesMeta =
      const VerificationMeta('todayMinutes');
  @override
  late final GeneratedColumn<int> todayMinutes = GeneratedColumn<int>(
      'today_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalCardsStudiedMeta =
      const VerificationMeta('totalCardsStudied');
  @override
  late final GeneratedColumn<int> totalCardsStudied = GeneratedColumn<int>(
      'total_cards_studied', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalSessionsCompletedMeta =
      const VerificationMeta('totalSessionsCompleted');
  @override
  late final GeneratedColumn<int> totalSessionsCompleted = GeneratedColumn<int>(
      'total_sessions_completed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalStudyTimeSecondsMeta =
      const VerificationMeta('totalStudyTimeSeconds');
  @override
  late final GeneratedColumn<int> totalStudyTimeSeconds = GeneratedColumn<int>(
      'total_study_time_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _todayResetDateMeta =
      const VerificationMeta('todayResetDate');
  @override
  late final GeneratedColumn<DateTime> todayResetDate =
      GeneratedColumn<DateTime>('today_reset_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        totalXp,
        level,
        currentStreak,
        longestStreak,
        lastStudyDate,
        dailyGoalCards,
        dailyGoalMinutes,
        todayCards,
        todayMinutes,
        totalCardsStudied,
        totalSessionsCompleted,
        totalStudyTimeSeconds,
        todayResetDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(Insertable<UserStatsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('total_xp')) {
      context.handle(_totalXpMeta,
          totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
          _longestStreakMeta,
          longestStreak.isAcceptableOrUnknown(
              data['longest_streak']!, _longestStreakMeta));
    }
    if (data.containsKey('last_study_date')) {
      context.handle(
          _lastStudyDateMeta,
          lastStudyDate.isAcceptableOrUnknown(
              data['last_study_date']!, _lastStudyDateMeta));
    }
    if (data.containsKey('daily_goal_cards')) {
      context.handle(
          _dailyGoalCardsMeta,
          dailyGoalCards.isAcceptableOrUnknown(
              data['daily_goal_cards']!, _dailyGoalCardsMeta));
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
          _dailyGoalMinutesMeta,
          dailyGoalMinutes.isAcceptableOrUnknown(
              data['daily_goal_minutes']!, _dailyGoalMinutesMeta));
    }
    if (data.containsKey('today_cards')) {
      context.handle(
          _todayCardsMeta,
          todayCards.isAcceptableOrUnknown(
              data['today_cards']!, _todayCardsMeta));
    }
    if (data.containsKey('today_minutes')) {
      context.handle(
          _todayMinutesMeta,
          todayMinutes.isAcceptableOrUnknown(
              data['today_minutes']!, _todayMinutesMeta));
    }
    if (data.containsKey('total_cards_studied')) {
      context.handle(
          _totalCardsStudiedMeta,
          totalCardsStudied.isAcceptableOrUnknown(
              data['total_cards_studied']!, _totalCardsStudiedMeta));
    }
    if (data.containsKey('total_sessions_completed')) {
      context.handle(
          _totalSessionsCompletedMeta,
          totalSessionsCompleted.isAcceptableOrUnknown(
              data['total_sessions_completed']!, _totalSessionsCompletedMeta));
    }
    if (data.containsKey('total_study_time_seconds')) {
      context.handle(
          _totalStudyTimeSecondsMeta,
          totalStudyTimeSeconds.isAcceptableOrUnknown(
              data['total_study_time_seconds']!, _totalStudyTimeSecondsMeta));
    }
    if (data.containsKey('today_reset_date')) {
      context.handle(
          _todayResetDateMeta,
          todayResetDate.isAcceptableOrUnknown(
              data['today_reset_date']!, _todayResetDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserStatsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStatsTableData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      totalXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_xp'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
      longestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}longest_streak'])!,
      lastStudyDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_study_date']),
      dailyGoalCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_goal_cards'])!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}daily_goal_minutes'])!,
      todayCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}today_cards'])!,
      todayMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}today_minutes'])!,
      totalCardsStudied: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_cards_studied'])!,
      totalSessionsCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}total_sessions_completed'])!,
      totalStudyTimeSeconds: attachedDatabase.typeMapping.read(DriftSqlType.int,
          data['${effectivePrefix}total_study_time_seconds'])!,
      todayResetDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}today_reset_date']),
    );
  }

  @override
  $UserStatsTableTable createAlias(String alias) {
    return $UserStatsTableTable(attachedDatabase, alias);
  }
}

class UserStatsTableData extends DataClass
    implements Insertable<UserStatsTableData> {
  /// User ID (primary key).
  final String userId;

  /// Total XP earned.
  final int totalXp;

  /// Current level.
  final int level;

  /// Current streak (consecutive days).
  final int currentStreak;

  /// Longest streak achieved.
  final int longestStreak;

  /// Last date the user studied.
  final DateTime? lastStudyDate;

  /// Daily goal: number of cards.
  final int dailyGoalCards;

  /// Daily goal: minutes of study.
  final int dailyGoalMinutes;

  /// Cards studied today.
  final int todayCards;

  /// Minutes studied today.
  final int todayMinutes;

  /// Total cards studied all time.
  final int totalCardsStudied;

  /// Total sessions completed.
  final int totalSessionsCompleted;

  /// Total study time in seconds.
  final int totalStudyTimeSeconds;

  /// Date when today counters were last reset.
  final DateTime? todayResetDate;
  const UserStatsTableData(
      {required this.userId,
      required this.totalXp,
      required this.level,
      required this.currentStreak,
      required this.longestStreak,
      this.lastStudyDate,
      required this.dailyGoalCards,
      required this.dailyGoalMinutes,
      required this.todayCards,
      required this.todayMinutes,
      required this.totalCardsStudied,
      required this.totalSessionsCompleted,
      required this.totalStudyTimeSeconds,
      this.todayResetDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['total_xp'] = Variable<int>(totalXp);
    map['level'] = Variable<int>(level);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastStudyDate != null) {
      map['last_study_date'] = Variable<DateTime>(lastStudyDate);
    }
    map['daily_goal_cards'] = Variable<int>(dailyGoalCards);
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    map['today_cards'] = Variable<int>(todayCards);
    map['today_minutes'] = Variable<int>(todayMinutes);
    map['total_cards_studied'] = Variable<int>(totalCardsStudied);
    map['total_sessions_completed'] = Variable<int>(totalSessionsCompleted);
    map['total_study_time_seconds'] = Variable<int>(totalStudyTimeSeconds);
    if (!nullToAbsent || todayResetDate != null) {
      map['today_reset_date'] = Variable<DateTime>(todayResetDate);
    }
    return map;
  }

  UserStatsTableCompanion toCompanion(bool nullToAbsent) {
    return UserStatsTableCompanion(
      userId: Value(userId),
      totalXp: Value(totalXp),
      level: Value(level),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastStudyDate: lastStudyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudyDate),
      dailyGoalCards: Value(dailyGoalCards),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      todayCards: Value(todayCards),
      todayMinutes: Value(todayMinutes),
      totalCardsStudied: Value(totalCardsStudied),
      totalSessionsCompleted: Value(totalSessionsCompleted),
      totalStudyTimeSeconds: Value(totalStudyTimeSeconds),
      todayResetDate: todayResetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(todayResetDate),
    );
  }

  factory UserStatsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStatsTableData(
      userId: serializer.fromJson<String>(json['userId']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      level: serializer.fromJson<int>(json['level']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastStudyDate: serializer.fromJson<DateTime?>(json['lastStudyDate']),
      dailyGoalCards: serializer.fromJson<int>(json['dailyGoalCards']),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
      todayCards: serializer.fromJson<int>(json['todayCards']),
      todayMinutes: serializer.fromJson<int>(json['todayMinutes']),
      totalCardsStudied: serializer.fromJson<int>(json['totalCardsStudied']),
      totalSessionsCompleted:
          serializer.fromJson<int>(json['totalSessionsCompleted']),
      totalStudyTimeSeconds:
          serializer.fromJson<int>(json['totalStudyTimeSeconds']),
      todayResetDate: serializer.fromJson<DateTime?>(json['todayResetDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'totalXp': serializer.toJson<int>(totalXp),
      'level': serializer.toJson<int>(level),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastStudyDate': serializer.toJson<DateTime?>(lastStudyDate),
      'dailyGoalCards': serializer.toJson<int>(dailyGoalCards),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
      'todayCards': serializer.toJson<int>(todayCards),
      'todayMinutes': serializer.toJson<int>(todayMinutes),
      'totalCardsStudied': serializer.toJson<int>(totalCardsStudied),
      'totalSessionsCompleted': serializer.toJson<int>(totalSessionsCompleted),
      'totalStudyTimeSeconds': serializer.toJson<int>(totalStudyTimeSeconds),
      'todayResetDate': serializer.toJson<DateTime?>(todayResetDate),
    };
  }

  UserStatsTableData copyWith(
          {String? userId,
          int? totalXp,
          int? level,
          int? currentStreak,
          int? longestStreak,
          Value<DateTime?> lastStudyDate = const Value.absent(),
          int? dailyGoalCards,
          int? dailyGoalMinutes,
          int? todayCards,
          int? todayMinutes,
          int? totalCardsStudied,
          int? totalSessionsCompleted,
          int? totalStudyTimeSeconds,
          Value<DateTime?> todayResetDate = const Value.absent()}) =>
      UserStatsTableData(
        userId: userId ?? this.userId,
        totalXp: totalXp ?? this.totalXp,
        level: level ?? this.level,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastStudyDate:
            lastStudyDate.present ? lastStudyDate.value : this.lastStudyDate,
        dailyGoalCards: dailyGoalCards ?? this.dailyGoalCards,
        dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
        todayCards: todayCards ?? this.todayCards,
        todayMinutes: todayMinutes ?? this.todayMinutes,
        totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
        totalSessionsCompleted:
            totalSessionsCompleted ?? this.totalSessionsCompleted,
        totalStudyTimeSeconds:
            totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
        todayResetDate:
            todayResetDate.present ? todayResetDate.value : this.todayResetDate,
      );
  UserStatsTableData copyWithCompanion(UserStatsTableCompanion data) {
    return UserStatsTableData(
      userId: data.userId.present ? data.userId.value : this.userId,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      level: data.level.present ? data.level.value : this.level,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastStudyDate: data.lastStudyDate.present
          ? data.lastStudyDate.value
          : this.lastStudyDate,
      dailyGoalCards: data.dailyGoalCards.present
          ? data.dailyGoalCards.value
          : this.dailyGoalCards,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
      todayCards:
          data.todayCards.present ? data.todayCards.value : this.todayCards,
      todayMinutes: data.todayMinutes.present
          ? data.todayMinutes.value
          : this.todayMinutes,
      totalCardsStudied: data.totalCardsStudied.present
          ? data.totalCardsStudied.value
          : this.totalCardsStudied,
      totalSessionsCompleted: data.totalSessionsCompleted.present
          ? data.totalSessionsCompleted.value
          : this.totalSessionsCompleted,
      totalStudyTimeSeconds: data.totalStudyTimeSeconds.present
          ? data.totalStudyTimeSeconds.value
          : this.totalStudyTimeSeconds,
      todayResetDate: data.todayResetDate.present
          ? data.todayResetDate.value
          : this.todayResetDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsTableData(')
          ..write('userId: $userId, ')
          ..write('totalXp: $totalXp, ')
          ..write('level: $level, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastStudyDate: $lastStudyDate, ')
          ..write('dailyGoalCards: $dailyGoalCards, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('todayCards: $todayCards, ')
          ..write('todayMinutes: $todayMinutes, ')
          ..write('totalCardsStudied: $totalCardsStudied, ')
          ..write('totalSessionsCompleted: $totalSessionsCompleted, ')
          ..write('totalStudyTimeSeconds: $totalStudyTimeSeconds, ')
          ..write('todayResetDate: $todayResetDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      totalXp,
      level,
      currentStreak,
      longestStreak,
      lastStudyDate,
      dailyGoalCards,
      dailyGoalMinutes,
      todayCards,
      todayMinutes,
      totalCardsStudied,
      totalSessionsCompleted,
      totalStudyTimeSeconds,
      todayResetDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStatsTableData &&
          other.userId == this.userId &&
          other.totalXp == this.totalXp &&
          other.level == this.level &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastStudyDate == this.lastStudyDate &&
          other.dailyGoalCards == this.dailyGoalCards &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.todayCards == this.todayCards &&
          other.todayMinutes == this.todayMinutes &&
          other.totalCardsStudied == this.totalCardsStudied &&
          other.totalSessionsCompleted == this.totalSessionsCompleted &&
          other.totalStudyTimeSeconds == this.totalStudyTimeSeconds &&
          other.todayResetDate == this.todayResetDate);
}

class UserStatsTableCompanion extends UpdateCompanion<UserStatsTableData> {
  final Value<String> userId;
  final Value<int> totalXp;
  final Value<int> level;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<DateTime?> lastStudyDate;
  final Value<int> dailyGoalCards;
  final Value<int> dailyGoalMinutes;
  final Value<int> todayCards;
  final Value<int> todayMinutes;
  final Value<int> totalCardsStudied;
  final Value<int> totalSessionsCompleted;
  final Value<int> totalStudyTimeSeconds;
  final Value<DateTime?> todayResetDate;
  final Value<int> rowid;
  const UserStatsTableCompanion({
    this.userId = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.level = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastStudyDate = const Value.absent(),
    this.dailyGoalCards = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.todayCards = const Value.absent(),
    this.todayMinutes = const Value.absent(),
    this.totalCardsStudied = const Value.absent(),
    this.totalSessionsCompleted = const Value.absent(),
    this.totalStudyTimeSeconds = const Value.absent(),
    this.todayResetDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStatsTableCompanion.insert({
    required String userId,
    this.totalXp = const Value.absent(),
    this.level = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastStudyDate = const Value.absent(),
    this.dailyGoalCards = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.todayCards = const Value.absent(),
    this.todayMinutes = const Value.absent(),
    this.totalCardsStudied = const Value.absent(),
    this.totalSessionsCompleted = const Value.absent(),
    this.totalStudyTimeSeconds = const Value.absent(),
    this.todayResetDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserStatsTableData> custom({
    Expression<String>? userId,
    Expression<int>? totalXp,
    Expression<int>? level,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<DateTime>? lastStudyDate,
    Expression<int>? dailyGoalCards,
    Expression<int>? dailyGoalMinutes,
    Expression<int>? todayCards,
    Expression<int>? todayMinutes,
    Expression<int>? totalCardsStudied,
    Expression<int>? totalSessionsCompleted,
    Expression<int>? totalStudyTimeSeconds,
    Expression<DateTime>? todayResetDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (totalXp != null) 'total_xp': totalXp,
      if (level != null) 'level': level,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastStudyDate != null) 'last_study_date': lastStudyDate,
      if (dailyGoalCards != null) 'daily_goal_cards': dailyGoalCards,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (todayCards != null) 'today_cards': todayCards,
      if (todayMinutes != null) 'today_minutes': todayMinutes,
      if (totalCardsStudied != null) 'total_cards_studied': totalCardsStudied,
      if (totalSessionsCompleted != null)
        'total_sessions_completed': totalSessionsCompleted,
      if (totalStudyTimeSeconds != null)
        'total_study_time_seconds': totalStudyTimeSeconds,
      if (todayResetDate != null) 'today_reset_date': todayResetDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStatsTableCompanion copyWith(
      {Value<String>? userId,
      Value<int>? totalXp,
      Value<int>? level,
      Value<int>? currentStreak,
      Value<int>? longestStreak,
      Value<DateTime?>? lastStudyDate,
      Value<int>? dailyGoalCards,
      Value<int>? dailyGoalMinutes,
      Value<int>? todayCards,
      Value<int>? todayMinutes,
      Value<int>? totalCardsStudied,
      Value<int>? totalSessionsCompleted,
      Value<int>? totalStudyTimeSeconds,
      Value<DateTime?>? todayResetDate,
      Value<int>? rowid}) {
    return UserStatsTableCompanion(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      dailyGoalCards: dailyGoalCards ?? this.dailyGoalCards,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      todayCards: todayCards ?? this.todayCards,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      totalSessionsCompleted:
          totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalStudyTimeSeconds:
          totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
      todayResetDate: todayResetDate ?? this.todayResetDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastStudyDate.present) {
      map['last_study_date'] = Variable<DateTime>(lastStudyDate.value);
    }
    if (dailyGoalCards.present) {
      map['daily_goal_cards'] = Variable<int>(dailyGoalCards.value);
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (todayCards.present) {
      map['today_cards'] = Variable<int>(todayCards.value);
    }
    if (todayMinutes.present) {
      map['today_minutes'] = Variable<int>(todayMinutes.value);
    }
    if (totalCardsStudied.present) {
      map['total_cards_studied'] = Variable<int>(totalCardsStudied.value);
    }
    if (totalSessionsCompleted.present) {
      map['total_sessions_completed'] =
          Variable<int>(totalSessionsCompleted.value);
    }
    if (totalStudyTimeSeconds.present) {
      map['total_study_time_seconds'] =
          Variable<int>(totalStudyTimeSeconds.value);
    }
    if (todayResetDate.present) {
      map['today_reset_date'] = Variable<DateTime>(todayResetDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsTableCompanion(')
          ..write('userId: $userId, ')
          ..write('totalXp: $totalXp, ')
          ..write('level: $level, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastStudyDate: $lastStudyDate, ')
          ..write('dailyGoalCards: $dailyGoalCards, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('todayCards: $todayCards, ')
          ..write('todayMinutes: $todayMinutes, ')
          ..write('totalCardsStudied: $totalCardsStudied, ')
          ..write('totalSessionsCompleted: $totalSessionsCompleted, ')
          ..write('totalStudyTimeSeconds: $totalStudyTimeSeconds, ')
          ..write('todayResetDate: $todayResetDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $FolderTableTable folderTable = $FolderTableTable(this);
  late final $DeckTableTable deckTable = $DeckTableTable(this);
  late final $CardTableTable cardTable = $CardTableTable(this);
  late final $TagTableTable tagTable = $TagTableTable(this);
  late final $CardTagTableTable cardTagTable = $CardTagTableTable(this);
  late final $StudySessionTableTable studySessionTable =
      $StudySessionTableTable(this);
  late final $CardSrsTableTable cardSrsTable = $CardSrsTableTable(this);
  late final $CardReviewTableTable cardReviewTable =
      $CardReviewTableTable(this);
  late final $UserStatsTableTable userStatsTable = $UserStatsTableTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final FolderDao folderDao = FolderDao(this as AppDatabase);
  late final DeckDao deckDao = DeckDao(this as AppDatabase);
  late final CardDao cardDao = CardDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final StudyDao studyDao = StudyDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userTable,
        folderTable,
        deckTable,
        cardTable,
        tagTable,
        cardTagTable,
        studySessionTable,
        cardSrsTable,
        cardReviewTable,
        userStatsTable
      ];
}

typedef $$UserTableTableCreateCompanionBuilder = UserTableCompanion Function({
  required String id,
  Value<String?> email,
  Value<String?> displayName,
  Value<bool> isAnonymous,
  required DateTime createdAt,
  Value<DateTime?> lastSyncAt,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$UserTableTableUpdateCompanionBuilder = UserTableCompanion Function({
  Value<String> id,
  Value<String?> email,
  Value<String?> displayName,
  Value<bool> isAnonymous,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSyncAt,
  Value<String?> remoteId,
  Value<int> rowid,
});

class $$UserTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserTableTable,
    UserTableData,
    $$UserTableTableFilterComposer,
    $$UserTableTableOrderingComposer,
    $$UserTableTableCreateCompanionBuilder,
    $$UserTableTableUpdateCompanionBuilder> {
  $$UserTableTableTableManager(_$AppDatabase db, $UserTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<bool> isAnonymous = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTableCompanion(
            id: id,
            email: email,
            displayName: displayName,
            isAnonymous: isAnonymous,
            createdAt: createdAt,
            lastSyncAt: lastSyncAt,
            remoteId: remoteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<bool> isAnonymous = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTableCompanion.insert(
            id: id,
            email: email,
            displayName: displayName,
            isAnonymous: isAnonymous,
            createdAt: createdAt,
            lastSyncAt: lastSyncAt,
            remoteId: remoteId,
            rowid: rowid,
          ),
        ));
}

class $$UserTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isAnonymous => $state.composableBuilder(
      column: $state.table.isAnonymous,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSyncAt => $state.composableBuilder(
      column: $state.table.lastSyncAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isAnonymous => $state.composableBuilder(
      column: $state.table.isAnonymous,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSyncAt => $state.composableBuilder(
      column: $state.table.lastSyncAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FolderTableTableCreateCompanionBuilder = FolderTableCompanion
    Function({
  required String id,
  required String name,
  required String userId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$FolderTableTableUpdateCompanionBuilder = FolderTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> userId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});

class $$FolderTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FolderTableTable,
    FolderTableData,
    $$FolderTableTableFilterComposer,
    $$FolderTableTableOrderingComposer,
    $$FolderTableTableCreateCompanionBuilder,
    $$FolderTableTableUpdateCompanionBuilder> {
  $$FolderTableTableTableManager(_$AppDatabase db, $FolderTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FolderTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FolderTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderTableCompanion(
            id: id,
            name: name,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String userId,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FolderTableCompanion.insert(
            id: id,
            name: name,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
        ));
}

class $$FolderTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FolderTableTable> {
  $$FolderTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$FolderTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FolderTableTable> {
  $$FolderTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DeckTableTableCreateCompanionBuilder = DeckTableCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String userId,
  Value<String?> folderId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$DeckTableTableUpdateCompanionBuilder = DeckTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> userId,
  Value<String?> folderId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});

class $$DeckTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeckTableTable,
    DeckTableData,
    $$DeckTableTableFilterComposer,
    $$DeckTableTableOrderingComposer,
    $$DeckTableTableCreateCompanionBuilder,
    $$DeckTableTableUpdateCompanionBuilder> {
  $$DeckTableTableTableManager(_$AppDatabase db, $DeckTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DeckTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DeckTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> folderId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeckTableCompanion(
            id: id,
            name: name,
            description: description,
            userId: userId,
            folderId: folderId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String userId,
            Value<String?> folderId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeckTableCompanion.insert(
            id: id,
            name: name,
            description: description,
            userId: userId,
            folderId: folderId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
        ));
}

class $$DeckTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get folderId => $state.composableBuilder(
      column: $state.table.folderId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DeckTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get folderId => $state.composableBuilder(
      column: $state.table.folderId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CardTableTableCreateCompanionBuilder = CardTableCompanion Function({
  required String id,
  required String deckId,
  required String front,
  required String back,
  Value<String?> hint,
  Value<String?> mediaPath,
  Value<String?> mediaType,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$CardTableTableUpdateCompanionBuilder = CardTableCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> front,
  Value<String> back,
  Value<String?> hint,
  Value<String?> mediaPath,
  Value<String?> mediaType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});

class $$CardTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTableTable,
    CardTableData,
    $$CardTableTableFilterComposer,
    $$CardTableTableOrderingComposer,
    $$CardTableTableCreateCompanionBuilder,
    $$CardTableTableUpdateCompanionBuilder> {
  $$CardTableTableTableManager(_$AppDatabase db, $CardTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CardTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CardTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<String> front = const Value.absent(),
            Value<String> back = const Value.absent(),
            Value<String?> hint = const Value.absent(),
            Value<String?> mediaPath = const Value.absent(),
            Value<String?> mediaType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTableCompanion(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            hint: hint,
            mediaPath: mediaPath,
            mediaType: mediaType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deckId,
            required String front,
            required String back,
            Value<String?> hint = const Value.absent(),
            Value<String?> mediaPath = const Value.absent(),
            Value<String?> mediaType = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTableCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            hint: hint,
            mediaPath: mediaPath,
            mediaType: mediaType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
        ));
}

class $$CardTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CardTableTable> {
  $$CardTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deckId => $state.composableBuilder(
      column: $state.table.deckId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get front => $state.composableBuilder(
      column: $state.table.front,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get back => $state.composableBuilder(
      column: $state.table.back,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get hint => $state.composableBuilder(
      column: $state.table.hint,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mediaPath => $state.composableBuilder(
      column: $state.table.mediaPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mediaType => $state.composableBuilder(
      column: $state.table.mediaType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get deletedAt => $state.composableBuilder(
      column: $state.table.deletedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CardTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CardTableTable> {
  $$CardTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deckId => $state.composableBuilder(
      column: $state.table.deckId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get front => $state.composableBuilder(
      column: $state.table.front,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get back => $state.composableBuilder(
      column: $state.table.back,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get hint => $state.composableBuilder(
      column: $state.table.hint,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mediaPath => $state.composableBuilder(
      column: $state.table.mediaPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mediaType => $state.composableBuilder(
      column: $state.table.mediaType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get deletedAt => $state.composableBuilder(
      column: $state.table.deletedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TagTableTableCreateCompanionBuilder = TagTableCompanion Function({
  required String id,
  required String name,
  required String color,
  required String userId,
  required DateTime createdAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$TagTableTableUpdateCompanionBuilder = TagTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> color,
  Value<String> userId,
  Value<DateTime> createdAt,
  Value<bool> isSynced,
  Value<String?> remoteId,
  Value<int> rowid,
});

class $$TagTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagTableTable,
    TagTableData,
    $$TagTableTableFilterComposer,
    $$TagTableTableOrderingComposer,
    $$TagTableTableCreateCompanionBuilder,
    $$TagTableTableUpdateCompanionBuilder> {
  $$TagTableTableTableManager(_$AppDatabase db, $TagTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TagTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TagTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagTableCompanion(
            id: id,
            name: name,
            color: color,
            userId: userId,
            createdAt: createdAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String color,
            required String userId,
            required DateTime createdAt,
            Value<bool> isSynced = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagTableCompanion.insert(
            id: id,
            name: name,
            color: color,
            userId: userId,
            createdAt: createdAt,
            isSynced: isSynced,
            remoteId: remoteId,
            rowid: rowid,
          ),
        ));
}

class $$TagTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TagTableTable> {
  $$TagTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TagTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TagTableTable> {
  $$TagTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSynced => $state.composableBuilder(
      column: $state.table.isSynced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CardTagTableTableCreateCompanionBuilder = CardTagTableCompanion
    Function({
  required String cardId,
  required String tagId,
  Value<int> rowid,
});
typedef $$CardTagTableTableUpdateCompanionBuilder = CardTagTableCompanion
    Function({
  Value<String> cardId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$CardTagTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTagTableTable,
    CardTagTableData,
    $$CardTagTableTableFilterComposer,
    $$CardTagTableTableOrderingComposer,
    $$CardTagTableTableCreateCompanionBuilder,
    $$CardTagTableTableUpdateCompanionBuilder> {
  $$CardTagTableTableTableManager(_$AppDatabase db, $CardTagTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CardTagTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CardTagTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> cardId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTagTableCompanion(
            cardId: cardId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cardId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTagTableCompanion.insert(
            cardId: cardId,
            tagId: tagId,
            rowid: rowid,
          ),
        ));
}

class $$CardTagTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CardTagTableTable> {
  $$CardTagTableTableFilterComposer(super.$state);
  ColumnFilters<String> get cardId => $state.composableBuilder(
      column: $state.table.cardId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tagId => $state.composableBuilder(
      column: $state.table.tagId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CardTagTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CardTagTableTable> {
  $$CardTagTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get cardId => $state.composableBuilder(
      column: $state.table.cardId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tagId => $state.composableBuilder(
      column: $state.table.tagId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$StudySessionTableTableCreateCompanionBuilder
    = StudySessionTableCompanion Function({
  required String id,
  Value<String?> deckId,
  required String userId,
  required String mode,
  required String status,
  required DateTime startedAt,
  Value<DateTime?> pausedAt,
  Value<DateTime?> completedAt,
  required int totalCards,
  Value<int> reviewedCards,
  Value<int> correctCount,
  Value<int> almostCount,
  Value<int> wrongCount,
  Value<int> xpEarned,
  Value<int> totalTimeSeconds,
  Value<int> rowid,
});
typedef $$StudySessionTableTableUpdateCompanionBuilder
    = StudySessionTableCompanion Function({
  Value<String> id,
  Value<String?> deckId,
  Value<String> userId,
  Value<String> mode,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> pausedAt,
  Value<DateTime?> completedAt,
  Value<int> totalCards,
  Value<int> reviewedCards,
  Value<int> correctCount,
  Value<int> almostCount,
  Value<int> wrongCount,
  Value<int> xpEarned,
  Value<int> totalTimeSeconds,
  Value<int> rowid,
});

class $$StudySessionTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudySessionTableTable,
    StudySessionTableData,
    $$StudySessionTableTableFilterComposer,
    $$StudySessionTableTableOrderingComposer,
    $$StudySessionTableTableCreateCompanionBuilder,
    $$StudySessionTableTableUpdateCompanionBuilder> {
  $$StudySessionTableTableTableManager(
      _$AppDatabase db, $StudySessionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$StudySessionTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$StudySessionTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> deckId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> totalCards = const Value.absent(),
            Value<int> reviewedCards = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> almostCount = const Value.absent(),
            Value<int> wrongCount = const Value.absent(),
            Value<int> xpEarned = const Value.absent(),
            Value<int> totalTimeSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionTableCompanion(
            id: id,
            deckId: deckId,
            userId: userId,
            mode: mode,
            status: status,
            startedAt: startedAt,
            pausedAt: pausedAt,
            completedAt: completedAt,
            totalCards: totalCards,
            reviewedCards: reviewedCards,
            correctCount: correctCount,
            almostCount: almostCount,
            wrongCount: wrongCount,
            xpEarned: xpEarned,
            totalTimeSeconds: totalTimeSeconds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> deckId = const Value.absent(),
            required String userId,
            required String mode,
            required String status,
            required DateTime startedAt,
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required int totalCards,
            Value<int> reviewedCards = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> almostCount = const Value.absent(),
            Value<int> wrongCount = const Value.absent(),
            Value<int> xpEarned = const Value.absent(),
            Value<int> totalTimeSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionTableCompanion.insert(
            id: id,
            deckId: deckId,
            userId: userId,
            mode: mode,
            status: status,
            startedAt: startedAt,
            pausedAt: pausedAt,
            completedAt: completedAt,
            totalCards: totalCards,
            reviewedCards: reviewedCards,
            correctCount: correctCount,
            almostCount: almostCount,
            wrongCount: wrongCount,
            xpEarned: xpEarned,
            totalTimeSeconds: totalTimeSeconds,
            rowid: rowid,
          ),
        ));
}

class $$StudySessionTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $StudySessionTableTable> {
  $$StudySessionTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deckId => $state.composableBuilder(
      column: $state.table.deckId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mode => $state.composableBuilder(
      column: $state.table.mode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startedAt => $state.composableBuilder(
      column: $state.table.startedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get pausedAt => $state.composableBuilder(
      column: $state.table.pausedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalCards => $state.composableBuilder(
      column: $state.table.totalCards,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get reviewedCards => $state.composableBuilder(
      column: $state.table.reviewedCards,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get correctCount => $state.composableBuilder(
      column: $state.table.correctCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get almostCount => $state.composableBuilder(
      column: $state.table.almostCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get wrongCount => $state.composableBuilder(
      column: $state.table.wrongCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get xpEarned => $state.composableBuilder(
      column: $state.table.xpEarned,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalTimeSeconds => $state.composableBuilder(
      column: $state.table.totalTimeSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$StudySessionTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $StudySessionTableTable> {
  $$StudySessionTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deckId => $state.composableBuilder(
      column: $state.table.deckId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mode => $state.composableBuilder(
      column: $state.table.mode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startedAt => $state.composableBuilder(
      column: $state.table.startedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get pausedAt => $state.composableBuilder(
      column: $state.table.pausedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalCards => $state.composableBuilder(
      column: $state.table.totalCards,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get reviewedCards => $state.composableBuilder(
      column: $state.table.reviewedCards,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get correctCount => $state.composableBuilder(
      column: $state.table.correctCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get almostCount => $state.composableBuilder(
      column: $state.table.almostCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get wrongCount => $state.composableBuilder(
      column: $state.table.wrongCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get xpEarned => $state.composableBuilder(
      column: $state.table.xpEarned,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalTimeSeconds => $state.composableBuilder(
      column: $state.table.totalTimeSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CardSrsTableTableCreateCompanionBuilder = CardSrsTableCompanion
    Function({
  required String cardId,
  required String deckId,
  required String userId,
  required String state,
  Value<int> repetitions,
  Value<double> easeFactor,
  Value<int> intervalDays,
  Value<DateTime?> lastReviewedAt,
  Value<DateTime?> nextReviewAt,
  Value<int> consecutiveCorrect,
  Value<int> totalReviews,
  Value<int> totalCorrect,
  Value<int> rowid,
});
typedef $$CardSrsTableTableUpdateCompanionBuilder = CardSrsTableCompanion
    Function({
  Value<String> cardId,
  Value<String> deckId,
  Value<String> userId,
  Value<String> state,
  Value<int> repetitions,
  Value<double> easeFactor,
  Value<int> intervalDays,
  Value<DateTime?> lastReviewedAt,
  Value<DateTime?> nextReviewAt,
  Value<int> consecutiveCorrect,
  Value<int> totalReviews,
  Value<int> totalCorrect,
  Value<int> rowid,
});

class $$CardSrsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardSrsTableTable,
    CardSrsTableData,
    $$CardSrsTableTableFilterComposer,
    $$CardSrsTableTableOrderingComposer,
    $$CardSrsTableTableCreateCompanionBuilder,
    $$CardSrsTableTableUpdateCompanionBuilder> {
  $$CardSrsTableTableTableManager(_$AppDatabase db, $CardSrsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CardSrsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CardSrsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> cardId = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<DateTime?> nextReviewAt = const Value.absent(),
            Value<int> consecutiveCorrect = const Value.absent(),
            Value<int> totalReviews = const Value.absent(),
            Value<int> totalCorrect = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardSrsTableCompanion(
            cardId: cardId,
            deckId: deckId,
            userId: userId,
            state: state,
            repetitions: repetitions,
            easeFactor: easeFactor,
            intervalDays: intervalDays,
            lastReviewedAt: lastReviewedAt,
            nextReviewAt: nextReviewAt,
            consecutiveCorrect: consecutiveCorrect,
            totalReviews: totalReviews,
            totalCorrect: totalCorrect,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cardId,
            required String deckId,
            required String userId,
            required String state,
            Value<int> repetitions = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<DateTime?> nextReviewAt = const Value.absent(),
            Value<int> consecutiveCorrect = const Value.absent(),
            Value<int> totalReviews = const Value.absent(),
            Value<int> totalCorrect = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardSrsTableCompanion.insert(
            cardId: cardId,
            deckId: deckId,
            userId: userId,
            state: state,
            repetitions: repetitions,
            easeFactor: easeFactor,
            intervalDays: intervalDays,
            lastReviewedAt: lastReviewedAt,
            nextReviewAt: nextReviewAt,
            consecutiveCorrect: consecutiveCorrect,
            totalReviews: totalReviews,
            totalCorrect: totalCorrect,
            rowid: rowid,
          ),
        ));
}

class $$CardSrsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CardSrsTableTable> {
  $$CardSrsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get cardId => $state.composableBuilder(
      column: $state.table.cardId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deckId => $state.composableBuilder(
      column: $state.table.deckId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get repetitions => $state.composableBuilder(
      column: $state.table.repetitions,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get easeFactor => $state.composableBuilder(
      column: $state.table.easeFactor,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get intervalDays => $state.composableBuilder(
      column: $state.table.intervalDays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastReviewedAt => $state.composableBuilder(
      column: $state.table.lastReviewedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get nextReviewAt => $state.composableBuilder(
      column: $state.table.nextReviewAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get consecutiveCorrect => $state.composableBuilder(
      column: $state.table.consecutiveCorrect,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalReviews => $state.composableBuilder(
      column: $state.table.totalReviews,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalCorrect => $state.composableBuilder(
      column: $state.table.totalCorrect,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CardSrsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CardSrsTableTable> {
  $$CardSrsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get cardId => $state.composableBuilder(
      column: $state.table.cardId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deckId => $state.composableBuilder(
      column: $state.table.deckId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get repetitions => $state.composableBuilder(
      column: $state.table.repetitions,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get easeFactor => $state.composableBuilder(
      column: $state.table.easeFactor,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get intervalDays => $state.composableBuilder(
      column: $state.table.intervalDays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastReviewedAt => $state.composableBuilder(
      column: $state.table.lastReviewedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get nextReviewAt => $state.composableBuilder(
      column: $state.table.nextReviewAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get consecutiveCorrect => $state.composableBuilder(
      column: $state.table.consecutiveCorrect,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalReviews => $state.composableBuilder(
      column: $state.table.totalReviews,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalCorrect => $state.composableBuilder(
      column: $state.table.totalCorrect,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CardReviewTableTableCreateCompanionBuilder = CardReviewTableCompanion
    Function({
  required String id,
  required String cardId,
  required String sessionId,
  required String userId,
  required String result,
  required DateTime reviewedAt,
  required int responseTimeMs,
  Value<int> rowid,
});
typedef $$CardReviewTableTableUpdateCompanionBuilder = CardReviewTableCompanion
    Function({
  Value<String> id,
  Value<String> cardId,
  Value<String> sessionId,
  Value<String> userId,
  Value<String> result,
  Value<DateTime> reviewedAt,
  Value<int> responseTimeMs,
  Value<int> rowid,
});

class $$CardReviewTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardReviewTableTable,
    CardReviewTableData,
    $$CardReviewTableTableFilterComposer,
    $$CardReviewTableTableOrderingComposer,
    $$CardReviewTableTableCreateCompanionBuilder,
    $$CardReviewTableTableUpdateCompanionBuilder> {
  $$CardReviewTableTableTableManager(
      _$AppDatabase db, $CardReviewTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CardReviewTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CardReviewTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cardId = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> result = const Value.absent(),
            Value<DateTime> reviewedAt = const Value.absent(),
            Value<int> responseTimeMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardReviewTableCompanion(
            id: id,
            cardId: cardId,
            sessionId: sessionId,
            userId: userId,
            result: result,
            reviewedAt: reviewedAt,
            responseTimeMs: responseTimeMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cardId,
            required String sessionId,
            required String userId,
            required String result,
            required DateTime reviewedAt,
            required int responseTimeMs,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardReviewTableCompanion.insert(
            id: id,
            cardId: cardId,
            sessionId: sessionId,
            userId: userId,
            result: result,
            reviewedAt: reviewedAt,
            responseTimeMs: responseTimeMs,
            rowid: rowid,
          ),
        ));
}

class $$CardReviewTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CardReviewTableTable> {
  $$CardReviewTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cardId => $state.composableBuilder(
      column: $state.table.cardId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get result => $state.composableBuilder(
      column: $state.table.result,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get reviewedAt => $state.composableBuilder(
      column: $state.table.reviewedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get responseTimeMs => $state.composableBuilder(
      column: $state.table.responseTimeMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CardReviewTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CardReviewTableTable> {
  $$CardReviewTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cardId => $state.composableBuilder(
      column: $state.table.cardId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get result => $state.composableBuilder(
      column: $state.table.result,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get reviewedAt => $state.composableBuilder(
      column: $state.table.reviewedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get responseTimeMs => $state.composableBuilder(
      column: $state.table.responseTimeMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UserStatsTableTableCreateCompanionBuilder = UserStatsTableCompanion
    Function({
  required String userId,
  Value<int> totalXp,
  Value<int> level,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<DateTime?> lastStudyDate,
  Value<int> dailyGoalCards,
  Value<int> dailyGoalMinutes,
  Value<int> todayCards,
  Value<int> todayMinutes,
  Value<int> totalCardsStudied,
  Value<int> totalSessionsCompleted,
  Value<int> totalStudyTimeSeconds,
  Value<DateTime?> todayResetDate,
  Value<int> rowid,
});
typedef $$UserStatsTableTableUpdateCompanionBuilder = UserStatsTableCompanion
    Function({
  Value<String> userId,
  Value<int> totalXp,
  Value<int> level,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<DateTime?> lastStudyDate,
  Value<int> dailyGoalCards,
  Value<int> dailyGoalMinutes,
  Value<int> todayCards,
  Value<int> todayMinutes,
  Value<int> totalCardsStudied,
  Value<int> totalSessionsCompleted,
  Value<int> totalStudyTimeSeconds,
  Value<DateTime?> todayResetDate,
  Value<int> rowid,
});

class $$UserStatsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserStatsTableTable,
    UserStatsTableData,
    $$UserStatsTableTableFilterComposer,
    $$UserStatsTableTableOrderingComposer,
    $$UserStatsTableTableCreateCompanionBuilder,
    $$UserStatsTableTableUpdateCompanionBuilder> {
  $$UserStatsTableTableTableManager(
      _$AppDatabase db, $UserStatsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserStatsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserStatsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<int> totalXp = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<DateTime?> lastStudyDate = const Value.absent(),
            Value<int> dailyGoalCards = const Value.absent(),
            Value<int> dailyGoalMinutes = const Value.absent(),
            Value<int> todayCards = const Value.absent(),
            Value<int> todayMinutes = const Value.absent(),
            Value<int> totalCardsStudied = const Value.absent(),
            Value<int> totalSessionsCompleted = const Value.absent(),
            Value<int> totalStudyTimeSeconds = const Value.absent(),
            Value<DateTime?> todayResetDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStatsTableCompanion(
            userId: userId,
            totalXp: totalXp,
            level: level,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastStudyDate: lastStudyDate,
            dailyGoalCards: dailyGoalCards,
            dailyGoalMinutes: dailyGoalMinutes,
            todayCards: todayCards,
            todayMinutes: todayMinutes,
            totalCardsStudied: totalCardsStudied,
            totalSessionsCompleted: totalSessionsCompleted,
            totalStudyTimeSeconds: totalStudyTimeSeconds,
            todayResetDate: todayResetDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<int> totalXp = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<DateTime?> lastStudyDate = const Value.absent(),
            Value<int> dailyGoalCards = const Value.absent(),
            Value<int> dailyGoalMinutes = const Value.absent(),
            Value<int> todayCards = const Value.absent(),
            Value<int> todayMinutes = const Value.absent(),
            Value<int> totalCardsStudied = const Value.absent(),
            Value<int> totalSessionsCompleted = const Value.absent(),
            Value<int> totalStudyTimeSeconds = const Value.absent(),
            Value<DateTime?> todayResetDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStatsTableCompanion.insert(
            userId: userId,
            totalXp: totalXp,
            level: level,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastStudyDate: lastStudyDate,
            dailyGoalCards: dailyGoalCards,
            dailyGoalMinutes: dailyGoalMinutes,
            todayCards: todayCards,
            todayMinutes: todayMinutes,
            totalCardsStudied: totalCardsStudied,
            totalSessionsCompleted: totalSessionsCompleted,
            totalStudyTimeSeconds: totalStudyTimeSeconds,
            todayResetDate: todayResetDate,
            rowid: rowid,
          ),
        ));
}

class $$UserStatsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalXp => $state.composableBuilder(
      column: $state.table.totalXp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get longestStreak => $state.composableBuilder(
      column: $state.table.longestStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastStudyDate => $state.composableBuilder(
      column: $state.table.lastStudyDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dailyGoalCards => $state.composableBuilder(
      column: $state.table.dailyGoalCards,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dailyGoalMinutes => $state.composableBuilder(
      column: $state.table.dailyGoalMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get todayCards => $state.composableBuilder(
      column: $state.table.todayCards,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get todayMinutes => $state.composableBuilder(
      column: $state.table.todayMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalCardsStudied => $state.composableBuilder(
      column: $state.table.totalCardsStudied,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalSessionsCompleted => $state.composableBuilder(
      column: $state.table.totalSessionsCompleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalStudyTimeSeconds => $state.composableBuilder(
      column: $state.table.totalStudyTimeSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get todayResetDate => $state.composableBuilder(
      column: $state.table.todayResetDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserStatsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalXp => $state.composableBuilder(
      column: $state.table.totalXp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get longestStreak => $state.composableBuilder(
      column: $state.table.longestStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastStudyDate => $state.composableBuilder(
      column: $state.table.lastStudyDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dailyGoalCards => $state.composableBuilder(
      column: $state.table.dailyGoalCards,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dailyGoalMinutes => $state.composableBuilder(
      column: $state.table.dailyGoalMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get todayCards => $state.composableBuilder(
      column: $state.table.todayCards,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get todayMinutes => $state.composableBuilder(
      column: $state.table.todayMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalCardsStudied => $state.composableBuilder(
      column: $state.table.totalCardsStudied,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalSessionsCompleted => $state.composableBuilder(
      column: $state.table.totalSessionsCompleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalStudyTimeSeconds => $state.composableBuilder(
      column: $state.table.totalStudyTimeSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get todayResetDate => $state.composableBuilder(
      column: $state.table.todayResetDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserTableTableTableManager get userTable =>
      $$UserTableTableTableManager(_db, _db.userTable);
  $$FolderTableTableTableManager get folderTable =>
      $$FolderTableTableTableManager(_db, _db.folderTable);
  $$DeckTableTableTableManager get deckTable =>
      $$DeckTableTableTableManager(_db, _db.deckTable);
  $$CardTableTableTableManager get cardTable =>
      $$CardTableTableTableManager(_db, _db.cardTable);
  $$TagTableTableTableManager get tagTable =>
      $$TagTableTableTableManager(_db, _db.tagTable);
  $$CardTagTableTableTableManager get cardTagTable =>
      $$CardTagTableTableTableManager(_db, _db.cardTagTable);
  $$StudySessionTableTableTableManager get studySessionTable =>
      $$StudySessionTableTableTableManager(_db, _db.studySessionTable);
  $$CardSrsTableTableTableManager get cardSrsTable =>
      $$CardSrsTableTableTableManager(_db, _db.cardSrsTable);
  $$CardReviewTableTableTableManager get cardReviewTable =>
      $$CardReviewTableTableTableManager(_db, _db.cardReviewTable);
  $$UserStatsTableTableTableManager get userStatsTable =>
      $$UserStatsTableTableTableManager(_db, _db.userStatsTable);
}
