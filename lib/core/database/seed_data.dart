import 'package:sqflite/sqflite.dart';

abstract final class SeedData {
  static const List<String> muscles = [
    'الصدر',
    'الظهر',
    'الكتفين',
    'البايسبس',
    'الترايسبس',
    'البطن',
    'الأرجل',
    'الساقين',
    'الصدر العلوي',
    'الصدر السفلي',
  ];

  static const Map<String, List<String>> exercisesByMuscle = {
    'الصدر': ['بنش برس', 'تفتيح دمبل', 'ضغط صدر جهاز'],
    'الظهر': ['سحب أمامي', 'تجديف بار', 'ديدليفت'],
    'الكتفين': ['ضغط كتف دمبل', 'رفرفة جانبية', 'رفرفة خلفية'],
    'البايسبس': ['كرل بار', 'كرل دمبل تبادلي', 'هامر كرل'],
    'الترايسبس': ['تمديد ترايسبس كابل', 'غطس متوازي', 'فرنش برس'],
    'البطن': ['كرنش', 'رفع أرجل', 'بلانك'],
    'الأرجل': ['سكوات', 'ليج برس', 'لانجز'],
    'الساقين': ['رفع سمانة واقف', 'رفع سمانة جالس', 'نط حبل'],
    'الصدر العلوي': ['بنش مائل', 'تفتيح مائل', 'ضغط مائل جهاز'],
    'الصدر السفلي': ['بنش مقلوب', 'متوازي صدر', 'كروس أوفر سفلي'],
  };

  static Future<void> seed(Database db) async {
    final muscleCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM muscles')) ?? 0;
    if (muscleCount == 0) {
      for (final muscle in muscles) {
        await db.insert('muscles', {'name': muscle, 'is_custom': 0});
      }
    }

    final rows = await db.query('muscles', columns: ['id', 'name']);
    final muscleIds = {for (final row in rows) row['name'] as String: row['id'] as int};

    final exerciseCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM exercises')) ?? 0;
    if (exerciseCount == 0) {
      for (final entry in exercisesByMuscle.entries) {
        final muscleId = muscleIds[entry.key];
        if (muscleId == null) continue;

        for (final exercise in entry.value) {
          await db.insert('exercises', {
            'name': exercise,
            'target_muscle_id': muscleId,
            'is_custom': 0,
          });
        }
      }
    }

    final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    if (userCount == 0) {
      await db.insert('users', {
        'name': 'المستخدم',
        'goal': 'BuildMuscle',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
