import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/match_record.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'froggle.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        played_at TEXT NOT NULL,
        score INTEGER NOT NULL,
        words_found INTEGER NOT NULL,
        valid_words INTEGER NOT NULL,
        rank INTEGER NOT NULL,
        total_players INTEGER NOT NULL,
        is_win INTEGER NOT NULL,
        is_solo INTEGER NOT NULL,
        game_duration INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User methods
  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Match methods
  Future<int> insertMatch(MatchRecord match) async {
    final db = await database;
    return await db.insert('matches', match.toMap());
  }

  Future<List<MatchRecord>> getMatchesByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'matches',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'played_at DESC',
    );
    return result.map((map) => MatchRecord.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final matches = await getMatchesByUserId(userId);
    if (matches.isEmpty) {
      return {
        'totalGames': 0,
        'wins': 0,
        'totalScore': 0,
        'avgScore': 0.0,
        'totalWords': 0,
        'avgWords': 0.0,
        'bestScore': 0,
        'winRate': 0.0,
        'soloGames': 0,
        'multiGames': 0,
      };
    }

    final totalGames = matches.length;
    final wins = matches.where((m) => m.isWin).length;
    final totalScore = matches.fold<int>(0, (sum, m) => sum + m.score);
    final totalWords = matches.fold<int>(0, (sum, m) => sum + m.validWords);
    final bestScore = matches.map((m) => m.score).reduce((a, b) => a > b ? a : b);
    final soloGames = matches.where((m) => m.isSolo).length;
    final multiGames = totalGames - soloGames;

    return {
      'totalGames': totalGames,
      'wins': wins,
      'totalScore': totalScore,
      'avgScore': totalScore / totalGames,
      'totalWords': totalWords,
      'avgWords': totalWords / totalGames,
      'bestScore': bestScore,
      'winRate': wins / totalGames * 100,
      'soloGames': soloGames,
      'multiGames': multiGames,
    };
  }
}
