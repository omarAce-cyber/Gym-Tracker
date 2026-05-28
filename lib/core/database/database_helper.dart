import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gym_tracker/core/database/seed_data.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'gym_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  weight REAL,
  height REAL,
  goal TEXT DEFAULT 'BuildMuscle',
  created_at TEXT NOT NULL
)
''');

        await db.execute('''
CREATE TABLE muscles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  is_custom INTEGER DEFAULT 0
)
''');

        await db.execute('''
CREATE TABLE exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_muscle_id INTEGER NOT NULL,
  is_custom INTEGER DEFAULT 0,
  FOREIGN KEY (target_muscle_id) REFERENCES muscles(id)
)
''');

        await db.execute('''
CREATE TABLE workout_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
)
''');

        await db.execute('''
CREATE TABLE workout_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  workout_session_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  weight REAL NOT NULL,
  reps INTEGER NOT NULL,
  sets INTEGER NOT NULL,
  notes TEXT,
  FOREIGN KEY (workout_session_id) REFERENCES workout_sessions(id),
  FOREIGN KEY (exercise_id) REFERENCES exercises(id)
)
''');

        await db.execute('''
CREATE TABLE meals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  image_path TEXT,
  weight_in_gram REAL NOT NULL,
  protein REAL NOT NULL,
  carbs REAL NOT NULL,
  fat REAL NOT NULL,
  calories REAL NOT NULL,
  notes TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
)
''');

        await db.execute('''
CREATE TABLE meal_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  meal_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  quantity_in_gram REAL NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (meal_id) REFERENCES meals(id)
)
''');

        await SeedData.seed(db);
      },
    );
  }
}
