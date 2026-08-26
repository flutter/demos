import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'permissions_plugin_platform_interface.dart';

/// An implementation of [PermissionsPluginPlatform] that uses method channels.
class MethodChannelPermissionsPlugin extends PermissionsPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('permissions_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
