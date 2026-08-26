import 'package:jni_leveldb/src/leveldb.dart';

void db() {
  final db = LevelDB.open('example.db');
  try {
    db.put('Akron', 'Ohio');
    db.put('Tampa', 'Florida');
    db.put('Cleveland', 'Ohio');
    db.put('Sunnyvale', 'California');

    print('Tampa is in ${db.get('Tampa')}');

    db.delete('Akron');

    print('\nEntries in database:');
    for (var entry in db.entries) {
      print('${entry.key}, ${entry.value}');
    }
  } finally {
    db.close();
  }
}
