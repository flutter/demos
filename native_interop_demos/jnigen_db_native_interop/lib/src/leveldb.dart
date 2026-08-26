import 'dart:convert';
import 'dart:typed_data';

import 'package:jni/jni.dart';
import 'package:jni_leveldb/gen/leveldb/java/io/File.dart' as java;
import 'package:jni_leveldb/gen/leveldb/org/iq80/leveldb/DB.dart';
import 'package:jni_leveldb/gen/leveldb/org/iq80/leveldb/Options.dart';
import 'package:jni_leveldb/gen/leveldb/org/iq80/leveldb/impl/Iq80DBFactory.dart';
import 'package:jni_leveldb/gen/leveldb/org/iq80/leveldb/impl/SeekingIteratorAdapter.dart';

extension on List<int> {
  JByteArray toJByteArray() {
    final array = JByteArray(length);
    array.setRange(0, length, this);
    return array;
  }
}

extension on JByteArray {
  Uint8List toUint8List() => Uint8List.fromList(getRange(0, length));
}

class LevelDB {
  final DB _db;

  LevelDB._(this._db);

  static LevelDB open(String path, {bool createIfMissing = true}) {
    final options = Options()..createIfMissing$1(createIfMissing);
    final file = java.File(path.toJString());
    final db = Iq80DBFactory.factory!.open(file, options);
    if (db == null) {
      throw Exception('Failed to open database at $path');
    }
    return LevelDB._(db);
  }

  void put(String key, String value) {
    putBytes(utf8.encode(key), utf8.encode(value));
  }

  void putBytes(List<int> key, List<int> value) {
    using((arena) {
      final jKey = key.toJByteArray()..releasedBy(arena);
      final jValue = value.toJByteArray()..releasedBy(arena);
      _db.put(jKey, jValue);
    });
  }

  String? get(String key) {
    final value = getBytes(utf8.encode(key));
    if (value == null) {
      return null;
    }
    return utf8.decode(value);
  }

  Uint8List? getBytes(List<int> key) {
    return using((arena) {
      final jKey = key.toJByteArray()..releasedBy(arena);
      final value = _db.get(jKey);
      if (value == null) {
        return null;
      }
      final bytes = value.toUint8List();
      value.release();
      return bytes;
    });
  }

  void delete(String key) {
    deleteBytes(utf8.encode(key));
  }

  void deleteBytes(List<int> key) {
    using((arena) {
      final jKey = key.toJByteArray()..releasedBy(arena);
      _db.delete(jKey);
    });
  }

  void close() {
    _db.release();
  }

  Iterable<MapEntry<String, String>> get entries sync* {
    final iterator = _db.iterator()?.as(SeekingIteratorAdapter.type);
    if (iterator == null) return;
    try {
      iterator.seekToFirst();
      while (iterator.hasNext()) {
        final entry = iterator.next();
        if (entry == null) continue;

        final keyBytes = entry.key;
        final valueBytes = entry.value;

        if (keyBytes == null || valueBytes == null) {
          keyBytes?.release();
          valueBytes?.release();
          entry.release();
          continue;
        }

        final key = utf8.decode(keyBytes.toUint8List());
        final value = utf8.decode(valueBytes.toUint8List());

        keyBytes.release();
        valueBytes.release();
        entry.release();

        yield MapEntry(key, value);
      }
    } finally {
      iterator.release();
    }
  }
}
