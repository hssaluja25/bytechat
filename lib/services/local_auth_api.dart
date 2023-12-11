import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  // A device is supported if it has either biometric support or it can
  // fall back to device credentials (meaning: pin/password/pattern)
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (error) {
      print('Error checking for device support: $error');
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final deviceSupported = await isDeviceSupported();
    if (!deviceSupported) {
      print('Device is not supported. Show alert dialog box');
      return false;
    } else {
      try {
        return await _auth.authenticate(
            localizedReason: 'Authenticate to access ByteChat',
            options: const AuthenticationOptions(
              stickyAuth: true,
              useErrorDialogs: true,
            ));
      } on PlatformException catch (error) {
        print('Error while trying to authenticate: $error');
        return false;
      }
    }
  }
}
