import 'package:gym_tracker/core/database/database_helper.dart';
import 'package:gym_tracker/features/profile/data/models/user_model.dart';

class ProfileRepository {
  ProfileRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<UserModel>> getAllUsers() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('users', orderBy: 'id ASC');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<int> createUser(UserModel user) async {
    final db = await _databaseHelper.database;
    return db.insert('users', user.toMap());
  }

  Future<int> updateUser(UserModel user) async {
    if (user.id == null) {
      throw ArgumentError('UserModel.id is required for update');
    }
    final db = await _databaseHelper.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<UserModel> getOrCreateDefaultUser() async {
    final users = await getAllUsers();
    if (users.isNotEmpty) return users.first;
    final user = UserModel(
      name: 'المستخدم',
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await createUser(user);
    return UserModel(
      id: id,
      name: user.name,
      weight: user.weight,
      height: user.height,
      goal: user.goal,
      createdAt: user.createdAt,
    );
  }
}
