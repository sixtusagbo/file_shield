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
    String p = await writeData(plainData, '${d.path}\\decrypted_$filename');
    logger.i("$p decrypted successfully");
  }

  static encryptData(List<int> plainString) {
    logger.i("Encrypting File...");
    final encrypted =
        MyEncrypt.myEncrypter.encryptBytes(plainString, iv: MyEncrypt.myIv);

    return encrypted.bytes;
  }

  static decryptData(Uint8List encData) {
    logger.i("File decryption in progress...");
    enc.Encrypted en = enc.Encrypted(encData);

    return MyEncrypt.myEncrypter.decryptBytes(en, iv: MyEncrypt.myIv);
  }

  /// Return file contents as bytes from an encrypted file
  static Future<Uint8List> _readData(String fileNameWithPath) async {
    logger.i("Reading data...");
    File f = File(fileNameWithPath);

    return await f.readAsBytes();
  }

  /// Write data bytes to a file
  static Future<String> writeData(
      List<int> dataToWrite, String fileNameWithPath) async {
    logger.i("Writing Data...");
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);

    return f.absolute.toString();
  }

  static Future<Directory> get appDocDirectory async {
    final Directory docDir = await getApplicationDocumentsDirectory();

    if (await Directory('${docDir.path}\\EasyRead File Shield').exists()) {
      return Directory('${docDir.path}\\EasyRead File Shield');
    } else {
      final appDocDir = await Directory('${docDir.path}\\EasyRead File Shield')
          .create(recursive: true);
      return appDocDir;
    }
  }
}
