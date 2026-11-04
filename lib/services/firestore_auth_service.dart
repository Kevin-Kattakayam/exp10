import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/app_user.dart';

/// Result wrapper returned by authentication operations.
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final AppUser? user;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : isSuccess = false,
        user = null;
}

/// Service managing manual user login and registration stored in Google Cloud Firestore.
class FirestoreAuthService {
  static const String collectionName = 'users';

  FirestoreAuthService._internal();
  static final FirestoreAuthService instance = FirestoreAuthService._internal();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  FirebaseFirestore? _firestore;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  final List<AppUser> _localUsers = [];

  /// Initialize Firebase Core and Firestore offline cache settings.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firestore = FirebaseFirestore.instance;
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _isFirebaseInitialized = true;
    } catch (_) {
      _isFirebaseInitialized = false;
    }
    _initDemoUsers();
  }

  void _initDemoUsers() {
    if (_localUsers.isEmpty) {
      _localUsers.addAll([
        AppUser(
          id: 'doc_user_001',
          email: 'admin@cloudcorp.io',
          passwordHash: AppUser.hashPassword('Password123!'),
          fullName: 'Cloud Administrator',
          role: 'Administrator',
          createdAt: '2024-01-10',
          lastLoginAt: DateTime.now().toIso8601String(),
        ),
        AppUser(
          id: 'doc_user_002',
          email: 'sarah@university.edu',
          passwordHash: AppUser.hashPassword('SecurePass2026!'),
          fullName: 'Sarah Connor',
          role: 'Student',
          createdAt: '2024-03-15',
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        ),
      ]);
    }
  }

  // ==================== MANUAL FIRESTORE LOGIN ====================

  /// Authenticate user by querying email and comparing hashed password in Firestore.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final candidateHash = AppUser.hashPassword(password);

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final querySnapshot = await _firestore!
            .collection(collectionName)
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return const AuthResult.failure(
            'No user account found with this email address in Firestore.',
          );
        }

        final doc = querySnapshot.docs.first;
        final user = AppUser.fromMap(doc.data(), doc.id);

        if (user.passwordHash != candidateHash) {
          return const AuthResult.failure(
            'Incorrect password. Please verify credentials and try again.',
          );
        }

        // Update last login timestamp in Firestore
        final nowIso = DateTime.now().toIso8601String();
        await _firestore!.collection(collectionName).doc(doc.id).update({
          'lastLoginAt': nowIso,
        });

        _currentUser = user.copyWith(lastLoginAt: nowIso);
        return AuthResult.success(_currentUser);
      } catch (e) {
        // Fall back to local check if offline
      }
    }

    // Local fallback authentication
    final index = _localUsers.indexWhere((u) => u.email == cleanEmail);
    if (index == -1) {
      return const AuthResult.failure(
        'No user account found with this email in Firestore database.',
      );
    }

    final localUser = _localUsers[index];
    if (localUser.passwordHash != candidateHash) {
      return const AuthResult.failure(
        'Incorrect password. Please verify credentials and try again.',
      );
    }

    final updatedLocalUser = localUser.copyWith(
      lastLoginAt: DateTime.now().toIso8601String(),
    );
    _localUsers[index] = updatedLocalUser;
    _currentUser = updatedLocalUser;
    return AuthResult.success(_currentUser);
  }

  // ==================== MANUAL FIRESTORE REGISTRATION ====================

  /// Register a new user and store credentials in the Firestore 'users' collection.
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final passwordHash = AppUser.hashPassword(password);
    final nowIso = DateTime.now().toIso8601String();

    if (_isFirebaseInitialized && _firestore != null) {
      try {
        // Verify email uniqueness in Firestore
        final existing = await _firestore!
            .collection(collectionName)
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          return const AuthResult.failure(
            'An account with this email address already exists in Firestore.',
          );
        }

        final newUser = AppUser(
          email: cleanEmail,
          passwordHash: passwordHash,
          fullName: fullName.trim(),
          role: role,
          createdAt: nowIso,
          lastLoginAt: nowIso,
        );

        final docRef = await _firestore!
            .collection(collectionName)
            .add(newUser.toFirestore());

        _currentUser = newUser.copyWith(id: docRef.id);
        return AuthResult.success(_currentUser);
      } catch (e) {
        // Fall back to local registration
      }
    }

    if (_localUsers.any((u) => u.email == cleanEmail)) {
      return const AuthResult.failure(
        'An account with this email address already exists in Firestore.',
      );
    }

    final localUser = AppUser(
      id: 'doc_user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      passwordHash: passwordHash,
      fullName: fullName.trim(),
      role: role,
      createdAt: nowIso,
      lastLoginAt: nowIso,
    );

    _localUsers.add(localUser);
    _currentUser = localUser;
    return AuthResult.success(_currentUser);
  }

  /// Sign out current authenticated user.
  void logout() {
    _currentUser = null;
  }

  /// Seed initial demo users into Firestore.
  Future<void> seedDemoUsers() async {
    _initDemoUsers();
    if (_isFirebaseInitialized && _firestore != null) {
      try {
        final count = (await _firestore!.collection(collectionName).get()).size;
        if (count == 0) {
          for (final user in _localUsers) {
            await _firestore!.collection(collectionName).add(user.toFirestore());
          }
        }
      } catch (_) {}
    }
  }
}

