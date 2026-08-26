import 'dart:io';
import 'package:jni/jni.dart';
import 'package:jni_leveldb/jni_leveldb.dart' as jni_leveldb;

const jarError = '';

void main(List<String> arguments) {
  final dylibDir = Platform.script.resolve('../build/jni_libs').toFilePath();
  const jarDir = './mvn_jar/';
  List<String> jars;
  try {
    jars = Directory(jarDir)
        .listSync()
        .map((e) => e.path)
        .where((path) => path.endsWith('.jar'))
        .toList();
  } on OSError catch (_) {
    stderr.writeln(jarError);
    return;
  }
  if (jars.isEmpty) {
    stderr.writeln(jarError);
    return;
  }
  Jni.spawn(dylibDir: dylibDir, classPath: jars);

  jni_leveldb.db();
}
