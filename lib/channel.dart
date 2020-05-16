import 'dart:convert';
import 'dart:developer' as log;

import 'package:dartis/dartis.dart';
import 'package:gcloud/storage.dart';
import 'package:mealbox_dart_bot/body.dart';
import 'package:mealbox_dart_bot/channel2.dart';
import 'package:pedantic/pedantic.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'mealbox_dart_bot.dart';

//Client _redis;
Commands<String, String> _commands;

///maytapi
const String _maytapiEnd =
    'https://api.maytapi.com/api/731b30d3-9f99-482f-9e0a-1b190bdab831';
const String _setWebHook = '/setWebHook';
const String myWebHook = 'https://e4ea98d4.ngrok.io/maytapi';
const String _pass =
    'EBAAB944A27812F3AB68C6E23498D070BB36CEFB25CC1A1A7B7C01C70066C4D3';

class MealboxDartBotChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
      (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"),
    );

    final client = await Client.connect('redis://localhost:6379');
    final commands = client.asCommands<String, String>();
    await commands.auth(_pass);
    await initBot(commands);
    await initMaytapi();
  }

  Future<void> initMaytapi() async {
    final http.Client client = http.Client();
    final http.Response response = await client.post(
      _maytapiEnd + _setWebHook,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'x-maytapi-key': 'a50bb09e-e8ad-420a-9454-4ddbf7afc5de',
      },
      body: json.encode({
        'webhook': myWebHook,
      }),
    );

    //print(response.body);
  }

  IamBot _bot;
  Future<void> initBot(Commands<String, String> commands) async {
    _bot = IamBot(commands);
    //await commands.del(keys: ['919964687717', '918x98xx21x4']);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        //print(d.toString());
        final Body body = Body(d, API.gupshup);
        //print(body);
        if (body.EVENT_TYPE == GSBody.MESSAGE) {
          unawaited(_bot.messageArrived(body));
        }

        return Response.accepted();
      },
    );

    router.route('/maytapi').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        final Body body = Body(d, API.maytapi);
        if (body.EVENT_TYPE == MBody.MESSAGE) {
          unawaited(_bot.messageArrived(body));
        }

        return Response.accepted();
      },
    );

    router.route('/addMenu').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        if (d.containsKey('iamyadunandansoyoushoulddothis') &&
            d.containsKey('menu')) {
          //_bot.addMenu(getMenu(d['menu']));
          final m = getMenu(d);
          if(m!=null){
            _bot.addMenu(m);
          } else {
            return Response.badRequest();
          }
        } else {
          return Response.badRequest();
        }

        return Response.accepted();
      },
    );

    router.route('/dumpRDB').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        if (d.containsKey('iamyadunandansoyoushoulddothis')) {
          await _bot.dump();
        } else {
          return Response.notFound();
        }

        return Response.accepted();
      },
    );

    final String _key = File('mealbox-1-d090895da4b9.json').readAsStringSync();
    router.route('/dumpToGoogle').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        if (d.containsKey('iamyadunandansoyoushoulddothis')) {
          if (FileSystemEntity.typeSync('dump.rdb') ==
              FileSystemEntityType.file) {
            final auth.ServiceAccountCredentials cred =
                auth.ServiceAccountCredentials.fromJson(_key);
            final List<String> scopes = []..addAll(Storage.SCOPES);

            final auth.AutoRefreshingAuthClient client =
                await auth.clientViaServiceAccount(cred, scopes);
            final Storage storage = Storage(client, 'mealbox-1');

            final Bucket bucket = storage.bucket('mealbox-rdb-dump');

            final f = await File('dump.rdb')
                .openRead()
                .pipe(bucket.write('dump.rdb'));
          } else {
            return Response.noContent();
          }
        } else {
          return Response.notFound();
        }

        return Response.accepted();
      },
    );

    return router;
  }

  Map<String,Map<String,String>> getMenu(Map<String, dynamic> map) {
    if (map.containsKey('menu')) {
      final Map<String, dynamic> map2 = Map.castFrom(map['menu'] as Map);
      Map<String,String> breakfast,lunch,dinner;

      if(map2.containsKey('breakfast_menu')&&map2.containsKey('lunch_menu')&&map2.containsKey('dinner_menu')){
        breakfast = Map.castFrom(map2['breakfast_menu'] as Map);
        lunch = Map.castFrom(map2['lunch_menu'] as Map);
        dinner = Map.castFrom(map2['dinner_menu'] as Map);
      }
      return {'breakfast_menu':breakfast,'lunch_menu':lunch,'dinner_menu':dinner};
    }
    return null;
  }
}
