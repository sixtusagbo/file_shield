import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_shield/util/dialog_helper.dart';
import 'package:file_shield/util/helpers.dart';
import 'package:file_shield/util/my_encrypt.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

const String title = 'EasyRead File Shield';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isDesktop =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  if (isDesktop) {
    setWindowTitle('$title - Powered by Listacc');
    setWindowMaxSize(const Size(768, 540));
    setWindowMinSize(const Size(512, 420));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text('File Shield', style: theme.textTheme.headlineSmall),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select a pdf file',
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
                onPressed: () {
                  if (selectedFiles == null) {
                    DialogHelper.displayDialog(
                      context: context,
                      description: 'No file selected',
                    );

                    return;
                  }

                  for (var file in selectedFiles!) {
                    _encrypt(file);
                  }
                },
                child: const Text('Encrypt'),
              ),
            ],
          ),
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
  void _encrypt(PlatformFile file) async {
    final Directory docDir = await MyEncrypt.appDocDirectory;
    String outputFilePath = '${docDir.path}\\${file.name}';

    logger.f('outputFilePath: $outputFilePath');

    final encResult =
        MyEncrypt.encryptData(await File(file.path!).readAsBytes());

    await MyEncrypt.writeData(encResult, outputFilePath);
  }
}