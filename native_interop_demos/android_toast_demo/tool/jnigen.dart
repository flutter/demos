import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/gen/'),
          structure: OutputStructure.packageStructure,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(addGradleDeps: true),
      classPath: [packageRoot.resolve('build/app/tmp/kotlin-classes/release')],
      classes: [
        'android.widget.Toast', // provided by Android OS
      ],
    ),
  );
}
