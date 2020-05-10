import 'dart:convert';
import 'dart:developer' as log;

import 'package:dartis/dartis.dart';
import 'package:http/http.dart' as http;
import 'package:mealbox_dart_bot/body.dart';
import 'package:http/http.dart' as http;

import 'mealbox_dart_bot.dart';
import 'misc.dart';

class MealboxDartBotChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final client = await Client.connect('redis://localhost:6379');
    final commands = client.asCommands<String, String>();
    await initRedis(client, commands);
  }

  //Client _redis;
  Commands<String, String> _commands;
  initRedis(Client client, Commands<String, String> commands) async {
    //_redis = client;
    _commands = commands;
    await _commands.del(keys: ['919964687717', '918x98xx21x4']);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/').linkFunction(
      (request) async {
        Map<String, dynamic> d = await request.body.decode();
        print(d.toString());
        log.log('-------------------------------------------------');
        final Body body = Body(d);
        print(body);
        print(
            '---------------------------------------------------------------------');
        if (body.type == Body.MESSAGE) {
          messageArrived(body);
        }

        return Response.accepted();
      },
    );

    return router;
  }

  //Handle normal messages from user
  messageArrived(Body body) async {
    String text = body.payLoad.dataPayload.text;
    if (body.payLoad.type == Payload.TEXT) {
      textMessageArrived(body);
    } else if(body.payLoad.type == Payload.LOCATION){
      locationMessageArrived(body);
    }
  }

  ///Handle the location messages arrived
  locationMessageArrived(Body body)async{
    var phone = body.payLoad.sender.phone;
    if((await _commands.exists(key: phone)) == 1){
      userExists(body);
    }
  }
  ///handle the text messages
  textMessageArrived(Body body) async {
    var phone = body.payLoad.sender.phone;
    if ((await _commands.exists(key: phone)) == 1) {
      userExists(body);
    } else {
      register(body.payLoad.sender);
    }
  }

  ///handle existing user who sent the message
  void userExists(Body body) async {
    ///get user data
    final map = await _commands.hgetall(body.payLoad.sender.phone);
    final User user = User(map);

    ///check if user is going through registration process
    if (user.asked.isNotEmpty) {
      userIncomplete(body, user);
    }
  }

  ///continue registration as the user is in registration process
  void userIncomplete(Body body, User user) {
    String nextMessage = '';
    if (user.asked == User.NAME) {
      final text = body.payLoad.dataPayload.text;
      final name = getNameFromText(text);
      ///we asked name in the last step, try to process name from the reply
      if (name.isEmpty) {
        nextMessage = 'tell me your name within two words..';
        sorryIDidntUnderstand(nextMessage, body, user);
      } else {
        user.name = name;
        nextMessage = 'Okay, we will use ${user.name} as your name.';
        askAddress(nextMessage,body,user);
      }
    }else if(user.asked==User.ADDRESS){
      final text = body.payLoad.dataPayload.text;
      final address = getAddressFromText(text);
      if(address.length==2){
        final nextMessage = 'Okay, we will use\n${address.first}\nPIN - ${address.last}\n as your mealbox delivery address..';
        user.address = address.first;
        user.pin = address.last;
        askLocation(nextMessage,body,user);
      } else if(address.length==1){
        final nextMessage = 'Okay, we will use\n${address.first} as your address.';
        user.address = address.first;
        askPIN(nextMessage,body,user);
      }
    } else if(user.asked==User.PIN){
      final text = body.payLoad.dataPayload.text;
      final pin = getPinFromText(text);
      if(pin.isNotEmpty){
        final nextMessage = 'Okay, we will use the PIN - $pin.';
        user.pin = pin;
        askLocation(nextMessage, body, user);
      }else{
        const nextMessage = 'I Didn\'t get the PIN you have sent.';
        askPIN(nextMessage, body, user);
      }
    } else if(user.asked==User.LOCATION){
      final longitude = body.payLoad.dataPayload.longitude;
      final latitude = body.payLoad.dataPayload.latitude;

    }
  }

  ///we accepted user's address and pin, now do a request for location
  askLocation(String s,Body body,User user)async{
    final String nextMessage = '$s\n\nI need your location so our delivery will be easier and faster\n*Send me your Location..*';

    ///save user deets for next session
    user.asked = User.LOCATION;
    await _commands.hmset(body.payLoad.sender.phone,hash: user.map);
    
    ///send message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///after asking the address,as the pincode is missing ask for pincode
  void askPIN(String s,Body body,User user)async{
    ///might look into making conversation more random
    final pins = User.pins.join(',\n');
    final String nextMessage = '$s\n\n*You\'ve missed the PIN code,we serve to these PIN codes\n$pins\nTell me your PIN code..';
    
    ///save user deets for next session
    user.asked = User.PIN;
    await _commands.hmset(body.payLoad.sender.phone,hash:user.map);

    ///send message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///after asking the name ask for address in one go
  void askAddress(String s,Body body,User user) async {
    final String nextMessage = '$s\n\n*Next for delivery purposes, tell me your complete address in one message..*(pin included)';

    ///save user deets for next session
    user.asked = User.ADDRESS;
    await _commands.hmset(body.payLoad.sender.phone,hash:user.map);
    ///send message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///we didnt understood the last message try to ask the same in different manner
  void sorryIDidntUnderstand(String s, Body body, User user) {
    final String nextMessage = 'Sorry I didn\'t undestand,\n\n$s';

    ///send the nextmessage
    post(body.payLoad.sender.phone, nextMessage);
  }

  //First this when you recieve a message
  void register(Sender sender) async {
    //TO-DO implement random wish
    await _commands.hmset(sender.phone, hash: User.userMap);
    await _commands.hmset(sender.phone, field: 'asked', value: User.NAME);
    post(
      sender.phone,
      'Hello ' +
          sender.name +
          ', wlecome to the club, please answer some questions to to setup your account.\n\n' +
          '*What is your full name?* (max two words)',
    );
  }

  //THE MESSAGE ENDPOINT TO SEND OUT WHATSAPPA MESSAGES
  String messageEnd = 'https://api.gupshup.io/sm/api/v1/msg';
  String gsk = '4aff89d8f1ce4b27cbf3a7d4e4e63ff4';
  String myNumber = '917834811114';
  String business = 'mealboxclub';
  //the post request towards gs
  void post(String toNumber, String text) async {
    print('to: $toNumber');
    var client = http.Client();
    var response = await client.post(messageEnd, headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      'apikey': gsk
    }, body: {
      'channel': 'whatsapp',
      'source': myNumber,
      'destination': toNumber,
      'src.name': business,
      'message': json.encode({
        'isHSM': 'false',
        'type': 'text',
        'text': text,
      },)
    },);

    print(response.body);
  }

  ///this request gets google reverse geocoding for the provided latLong
  final String _gk = 'AIzaSyCj8Rpr-khGa_vmJ3cviQ1IlprhNVKUOQQ';
  final String _geocodeEnd = 'https://maps.googleapis.com/maps/api/geocode/json?';
  
  void postForGeocode(String latLongSeperatedByComma)async{
    var url = '${_geocodeEnd}latlng=${latLongSeperatedByComma}&key=$_gk';
    var client = http.Client();
    var response = await client.get(url);
    print(response);
  }
}
