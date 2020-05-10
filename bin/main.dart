import 'package:mealbox_dart_bot/mealbox_dart_bot.dart';

Future main() async {
  final app = Application<MealboxDartBotChannel>()
      ..options.configurationFilePath = "config.yaml"
      ..options.port = 3000;

  final count = Platform.numberOfProcessors ~/ 2;
  await app.start(numberOfInstances: count > 0 ? count : 1);

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}