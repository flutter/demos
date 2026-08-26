# jni_leveldb

A sample command-line application demonstrating how to create an idiomatic Dart wrapper around a Java implementation of LevelDB, a fast key-value storage library. This project showcases the evolution of a LevelDB wrapper from raw JNI bindings to a safe, clean, and Dart-native API using `jnigen`.

## Prerequisites

- Java Development Kit (JDK) version 1.8 or later must be installed, and the `JAVA_HOME` environment variable must be set to its location.

## Setup and Running

1.  **Generate Bindings and Build JNI code:**

    Build the JNI native library and run `tool/jnigen.dart` to download dependencies and generate Dart bindings:

    ```bash
    dart run jni:setup
    dart run tool/jnigen.dart
    ```

2.  **Run the application:**

    ```bash
    dart run bin/jni_leveldb.dart
    ```

## From Raw Bindings to an Idiomatic Dart API

The initial output of `jnigen` provides a low-level, direct mapping of the Java API. Using this directly in application code can be verbose, unsafe, and unidiomatic. This project demonstrates how to build a better wrapper by addressing common pitfalls.

### 1. Resource Management

JNI objects are handles to resources in the JVM. Failing to release them causes memory leaks.

**The Problem:** Forgetting to call `release()` on JNI objects.

**The Solution:** The best practice is to use the `using(Arena arena)` block, which automatically manages releasing all objects allocated within it, making your code safer and cleaner. For objects that live longer, you must manually call `release()`.

*Example from the wrapper:*
```dart
void putBytes(List<int> key, List<int> value) {
  using((arena) {
    final jKey = key.toJByteArray()..releasedBy(arena);
    final jValue = value.toJByteArray()..releasedBy(arena);
    _db.put(jKey, jValue);
  });
}
```

### 2. Idiomatic API Design and Type Handling

Raw bindings expose Java's conventions and require manual, repetitive type conversions. A wrapper class should expose a clean, Dart-like API.

**The Problem:** Java method names (`createIfMissing$1`) and types (`JString`, `JByteArray`) are exposed directly to the application code.

**The Solution:** Create a wrapper class that exposes methods with named parameters and standard Dart types (`String`, `Uint8List`), handling all the JNI conversions internally.

*The Improved API:*
```dart
static LevelDB open(String path, {bool createIfMissing = true}) { ... }
void put(String key, String value) { ... }
String? get(String key) { ... }
```

This allows for clean, simple iteration in the application code:
```dart
for (var entry in db.entries) {
  print('${entry.key}, ${entry.value}');
}
```

### 3. JVM Initialization

The JVM is a process-level resource and should be initialized only once when the application starts.

**The Problem:** Calling `Jni.spawn()` inside library code.

**The Solution:** `Jni.spawn()` belongs in a location where it will be called once, like your application's `main()` function, not in the library. In this example, the library code should assume the JVM is already running.

*Correct Usage in `bin/jni_leveldb.dart`:*
```dart
void main(List<String> arguments) {
  // ... find JARs and dynamic library path ...
  Jni.spawn(dylibDir: dylibDir, classPath: jars); // Spawn the JVM once.
  db();                                          // Run the application logic.
}
```

### The Final Result

By applying these principles, the application logic becomes simple, readable, and free of JNI-specific details.

*Final Application Code:*
```dart
import 'package:jni_leveldb/src/leveldb.dart';

void db() {
  final db = LevelDB.open('example.db');
  try {
    db.put('Akron', 'Ohio');
    db.put('Tampa', 'Florida');
    db.put('Cleveland', 'Ohio');

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
```