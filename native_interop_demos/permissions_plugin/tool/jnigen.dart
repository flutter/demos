import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/gen/android.g.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(addGradleDeps: true, androidExample: 'example/'),
      classPath: [packageRoot.resolve('build/app/tmp/kotlin-classes/release')],
      classes: [
        // provided by Android OS
        'android.app.Application',
        'androidx.activity.ComponentActivity',
        'androidx.fragment.app.FragmentActivity',
        'androidx.activity.result.ActivityResult',
        'androidx.core.app.ActivityCompat',
        'androidx.activity.result.ActivityResultCallback',
        'androidx.activity.result.ActivityResultLauncher',
        'androidx.activity.result.contract.ActivityResultContract',
        'android.content.Intent',
        //'android.content.Context',
        'androidx.core.content.ContextCompat',
        'android.Manifest',
        'android.content.pm.PackageManager'
      ],
    ),
  );
}
