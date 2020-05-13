import 'dart:convert';
import 'dart:developer' as log;

import 'package:dartis/dartis.dart';
import 'package:mealbox_dart_bot/body.dart';
import 'package:mealbox_dart_bot/channel2.dart';
import 'package:pedantic/pedantic.dart';
import 'package:http/http.dart' as http;

import 'mealbox_dart_bot.dart';

//Client _redis;
Commands<String, String> _commands;

///maytapi
const String _maytapiEnd =
    'https://api.maytapi.com/api/731b30d3-9f99-482f-9e0a-1b190bdab831';
const String _setWebHook = '/setWebHook';
const String myWebHook = 'https://b59d5313.ngrok.io/maytapi';

class MealboxDartBotChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final client = await Client.connect('redis://localhost:6379');
    final commands = client.asCommands<String, String>();
    await commands.auth(
        'EBAAB944A27812F3AB68C6E23498D070BB36CEFB25CC1A1A7B7C01C70066C4D3');
    await initBot(commands);
    await initMaytapi();
  }

  Future<void> initMaytapi() async {
    final http.Client client = http.Client();
    final http.Response response = await client.post(
      _maytapiEnd+_setWebHook,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'x-maytapi-key': 'a50bb09e-e8ad-420a-9454-4ddbf7afc5de',
      },
      body: json.encode({
        'webhook': myWebHook,
      }),
    );

    print(response.body);
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
        final Body body = Body(d);
        //print(body);
        if (body.type == Body.MESSAGE) {
          unawaited(_bot.messageArrived(body));
        }

        return Response.accepted();
      },
    );

    router.route('/maytapi').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        print(d.toString());
        if (d['type'] as String == 'message') {
          return Response.ok('hello........');
        }
        return Response.accepted();
      },
    );

    return router;
  }
}
