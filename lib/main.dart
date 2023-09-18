import 'dart:io';

import 'package:file_shield/home_view.dart';
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

final darkNotifier = ValueNotifier<bool>(true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: darkNotifier,
        builder: (_, isDark, __) {
          return MaterialApp(
            title: title,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const HomeView(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
