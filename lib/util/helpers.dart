import 'package:logger/logger.dart';

Logger logger = Logger(
  // Customize the printer
  printer: PrettyPrinter(
    methodCount: 0,
    printTime: false,
  ),
);
