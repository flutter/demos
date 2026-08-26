# permissions_plugin

Demonstrates how to use `jnigen` and native interop to create a plugin to query and request Android permissions.

## To build and run

1. Build the example app to compile Kotlin classes and prepare Gradle dependencies:
   ```sh
   cd example && flutter build apk && cd ..
   ```

2. Generate JNI bindings from the plugin root:
   ```sh
   dart run tool/jnigen.dart
   ```

3. Run the example app:
   ```sh
   cd example && flutter run
   ```
