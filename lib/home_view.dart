import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_shield/main.dart';
import 'package:file_shield/util/dialog_helper.dart';
import 'package:file_shield/util/helpers.dart';
import 'package:file_shield/util/my_encrypt.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String fileName = 'Pick';
  List<PlatformFile>? selectedFiles;
  bool showDecryptButton = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    darkNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = darkNotifier.value;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text('File Shield', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select pdf file(s)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _readFile,
                icon: const Icon(Icons.edit),
                label: Text(fileName),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 35),
              OutlinedButton(
                onPressed: () async {
                  if (selectedFiles == null) {
                    DialogHelper.displayDialog(
                      context: context,
                      description: 'No file selected',
                    );

                    return;
                  }
                  final Directory docDir = await MyEncrypt.appDocDirectory;

                  await Future.forEach(
                    selectedFiles!,
                    (file) async => await _encrypt(file),
                  ).then((_) {
                    DialogHelper.displayDialog(
                      context: context,
                      title: 'Operation Completed',
                      description:
                          'Encrypted successfully and stored at:\n${docDir.path}',
                      actionText: 'Open',
                      onPressed: _openStorageFolder,
                      cancelAction: () => Navigator.pop(context),
                    );
                  });
                },
                child: const Text('Encrypt'),
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Settings',
                style: theme.textTheme.titleMedium,
              ),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDark,
                onChanged: (v) {
                  isDark = !isDark;
                  darkNotifier.value = isDark;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;

      setState(() {
        if (files.length == 1) {
          fileName = files.single.name;
        } else {
          fileName = '${files.length} files selected';
        }

        selectedFiles = files;
      });
    } else {
      return;
    }
  }

  /// Encrypt the file when user has selected a file
  Future<void> _encrypt(PlatformFile file) async {
    final Directory docDir = await MyEncrypt.appDocDirectory;
    String outputFilePath = '${docDir.path}\\${file.name}';

    final encResult =
        MyEncrypt.encryptData(await File(file.path!).readAsBytes());

    await MyEncrypt.writeData(encResult, outputFilePath);
  }

  void _openStorageFolder() async {
    final Directory docDir = await MyEncrypt.appDocDirectory;
    final Uri uri = Uri.file(docDir.absolute.path);

    await launchUrl(uri);
  }
}
