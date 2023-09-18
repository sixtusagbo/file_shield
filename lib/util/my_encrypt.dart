import 'dart:io';

import 'package:file_shield/util/helpers.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider/path_provider.dart';

class MyEncrypt {
  // Change the key and iv before production deployment
  static final myKey = enc.Key.fromUtf8('abcdefghijklmnop');
  static final myIv = enc.IV.fromUtf8("abcdefghijklmnop");
  static final myEncrypter =
      enc.Encrypter(enc.AES(myKey, mode: enc.AESMode.cbc));

  /// Read data from an encrypted file and decrypt it
  static Future<void> getNormalFile(Directory d, String filename) async {
    Uint8List encData = await _readData('${d.path}\\$filename');
    var plainData = await decryptData(encData);
    await writeData(plainData, '${d.path}\\decrypted_$filename');
  }

  static encryptData(List<int> plainString) {
    final encrypted =
        MyEncrypt.myEncrypter.encryptBytes(plainString, iv: MyEncrypt.myIv);

    return encrypted.bytes;
  }

  static decryptData(Uint8List encData) {
    enc.Encrypted en = enc.Encrypted(encData);

    return MyEncrypt.myEncrypter.decryptBytes(en, iv: MyEncrypt.myIv);
  }

  /// Return file contents as bytes from an encrypted file
  static Future<Uint8List> _readData(String fileNameWithPath) async {
    File f = File(fileNameWithPath);

    return await f.readAsBytes();
  }

  /// Write data bytes to a file
  static Future<String> writeData(
      List<int> dataToWrite, String fileNameWithPath) async {
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);

    return f.absolute.toString();
  }

  static Future<Directory> get appDocDirectory async {
    final Directory docDir = await getApplicationDocumentsDirectory();
    const String folderName = 'EasyRead-FileShield';
    final Directory appDir = Directory('${docDir.path}\\$folderName');

    if (await appDir.exists()) {
      return appDir;
    } else {
      final appDocDir = await appDir.create(recursive: true);
      return appDocDir;
    }
  }
}
