import 'package:gcloud/storage.dart';
import 'package:mealbox_dart_bot/mealbox_dart_bot.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;



Future main() async {
  await getRDB();

  final Process _redis =
      await Process.start('redis-6.0.1/src/redis-server', ['redis.conf']);

  final app = Application<MealboxDartBotChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = getPort();

  final count = Platform.numberOfProcessors ~/ 2;
  await app.start(numberOfInstances: count > 0 ? count : 1);

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}

int getPort() {
  return const int.fromEnvironment('PORT', defaultValue: 8080);
}

final String _key = File('mealbox-1-d090895da4b9.json').readAsStringSync();

Future<void> getRDB() async {
  try{
    final auth.ServiceAccountCredentials cred =
      auth.ServiceAccountCredentials.fromJson(_key);
  final List<String> scopes = []..addAll(Storage.SCOPES);

  final auth.AutoRefreshingAuthClient client =
      await auth.clientViaServiceAccount(cred, scopes);
  final Storage storage = Storage(client, 'mealbox-1');

  final Bucket bucket = storage.bucket('mealbox-rdb-dump');

  var f = await bucket.read('dump.rdb').pipe(File('dump.rdb').openWrite());

  print(f);
  } catch(e){
    print(e);
  }
}
