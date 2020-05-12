import 'dart:convert';
import 'dart:developer' as log;

import 'package:dartis/dartis.dart';
import 'package:http/http.dart' as http;
import 'package:mealbox_dart_bot/body.dart';
import 'package:pedantic/pedantic.dart';

import 'mealbox_dart_bot.dart';
import 'misc.dart';


class MealboxDartBotChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final client = await Client.connect('redis://localhost:6379');
    final commands = client.asCommands<String, String>();
    await commands.auth(
        'EBAAB944A27812F3AB68C6E23498D070BB36CEFB25CC1A1A7B7C01C70066C4D3');
    await initRedis(client, commands);
  }

  //Client _redis;
  Commands<String, String> _commands;
  Future<void> initRedis(
      Client client, Commands<String, String> commands) async {
    //_redis = client;
    _commands = commands;
    //await _commands.del(keys: ['919964687717', '918x98xx21x4']);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/').linkFunction(
      (request) async {
        final Map<String, dynamic> d = await request.body.decode();
        print(d.toString());
        log.log('-------------------------------------------------');
        final Body body = Body(d);
        print(body);
        print(
            '---------------------------------------------------------------------');
        if (body.type == Body.MESSAGE) {
          unawaited(messageArrived(body));
        }

        return Response.accepted();
      },
    );

    router.route('/mercury').linkFunction(
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

  //Handle normal messages from user
  Future<void> messageArrived(Body body) async {
    final String text = body.payLoad.dataPayload.text;
    if (body.payLoad.type == Payload.TEXT) {
      await textMessageArrived(body);
    } else if (body.payLoad.type == Payload.LOCATION) {
      await locationMessageArrived(body);
    }
  }

  ///Handle the location messages arrived
  Future<void> locationMessageArrived(Body body) async {
    final phone = body.payLoad.sender.phone;
    if ((await _commands.exists(key: phone)) == 1) {
      userExists(body);
    }
  }

  ///handle the text messages
  Future<void> textMessageArrived(Body body) async {
    final phone = body.payLoad.sender.phone;
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

    ///check for keywords from existing user
    final text = body.payLoad.dataPayload.text;
    final keyword = getKeyWordFromText(text);
    if (keyword.isEmpty) {
      ///check if user is going through registration process
      if (user.asked.isNotEmpty) {
        await userIncomplete(body, user);
      }
    } else {
      ///process the keyword command
      processKeyWord(keyword, body, user);
    }
  }

  ///proceed with finding and processing the key word
  void processKeyWord(String keyword, Body body, User user) {
    switch (keyword) {
      case Keywords.CANCEL:
        {
          cancelLastRequest(body, user);
        }
        break;
      case Keywords.CHANGE_NUMBER:
        {
          addNewNumber(body, user);
        }
        break;
      case Keywords.OPTIONS:
        {
          sendFullOptions(body, user);
        }
        break;
      case Keywords.ACCOUNT:
        {
          sendAccountDeets(body, user);
        }
        break;
      case Keywords.CHANGE_DETAILS:
        {
          resetDatails(body, user);
        }
        break;
      case Keywords.YES:
        {
          acknowledgement(body, user);
        }
        break;
      case Keywords.CHANGE_ADDRESS:
        {
          resetUserAddress(body, user);
        }
        break;
      case Keywords.CHANGE_NAME:
        {
          resetUserName(body, user);
        }
        break;

      case Keywords.CHANGE_LOCATION:
        {
          resetUserLocation(body, user);
        }
        break;
      default:
        {
          ///this case must never happen
          sorryIDidntUnderstand('', body, user);
          throw Exception(
              'ThisMustNotHaveHappenedError while processing keyword $keyword');
        }
    }
  }

  ///user wants to cancel the last request
  void cancelLastRequest(Body body, User user) async {
    if (user.asked == User.PHONE) {
      ///phone request can be cancelled
      user.asked = '';

      ///save the session
      await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

      ///post ok cancelled
      final nextMessage =
          'Okay change request cancelled..check all details by sending'
          ' *${Keywords.ACCOUNT.toLowerCase()}*';

      ///post the message
      post(body.payLoad.sender.phone, nextMessage);
    } else {
      ///we dont know why customer asked cancellation we dont know how to handle the request
      sorryIDidntUnderstand('Please give the details requested..', body, user);
    }
  }

  ///user wants to update the contact number
  void addNewNumber(Body body, User user) async {
    ///prepare next Message
    final String nextMessage =
        'Your existing contact number for phone call from our side is *${get10NumberPhone(user.phone)}*\n*send the new 10 digit phone number to update..*';

    ///set asked so we can process the reply next session
    user.asked = User.PHONE;

    ///save session
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///post the message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///user wants all the details about their account
  void sendAccountDeets(Body body, User user) async {
    final nextMessage = 'Fallowing is your details with us'
        '\n_Name:_ ${user.name}'
        '\n_Number:_ ${get10NumberPhone(user.phone)}'
        '\n_Address:_ ${user.address}'
        '\n_PIN:_ ${user.pin}';

    ///send the message formatted
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///user wants to change the location
  void resetUserLocation(Body body, User user) async {
    ///prepare the next message
    const nextMessage =
        'Your location has been removed,\n*Please send me your new location..*';

    ///set asked to [User.LOCATION]
    user.asked = User.LOCATION;

    ///save the session
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send the next message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///user wants to reset name
  void resetUserName(Body body, User user) async {
    ///prepare the next message
    const nextMessage =
        'Your name has been removed,\n*Please send me your new name..*';

    ///set asked to [User.NAME]
    user.asked = User.NAME;

    ///save the session
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send the next message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///user said yes or acknowledged for the last message
  void acknowledgement(Body body, User user) {
    ///check which was the request to modification in the last session
    final keyword = user.keyword;
    switch (keyword) {
      case Keywords.CHANGE_DETAILS:
        {
          resetDetailsAcknowledged(body, user);
        }

        break;
      default:
        {
          throw Exception('ThisShouldNeverHaveHappened');
        }
    }
  }

  ///the last reset all details request was acknowldged
  void resetDetailsAcknowledged(Body body, User user) async {
    const nextMessage =
        'All your account details have been reset..please setup new details';

    ///remove all the details from db
    await _commands.hmset(body.payLoad.sender.phone, hash: User.userMap);

    ///post the confirmation regarding the removal
    post(body.payLoad.sender.phone, nextMessage);

    ///wait a bit
    await Future.delayed(const Duration(milliseconds: 500));
    register(body.payLoad.sender);
  }

  ///before reset user details ask acknowledgement
  void resetDatails(Body body, User user) async {
    const nextMessage =
        '*Reset your details?*\nI will ask all the details again to setup your account.. send yes to reset';

    ///set keyword identification for next session
    user.keyword = Keywords.CHANGE_DETAILS;

    ///save session
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///post next message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///remove the existing address and ask for the new
  void resetUserAddress(Body body, User user) {
    final nextMessage =
        'Your existing address\n*${user.address}*\n*${user.pin}* is removed';
    user.address = '';
    user.pin = '';
    askAddress(nextMessage, body, user);
  }

  ///handle updation complete called when every field in [User] is filled
  void updationDone(String s, Body body, User user) async {
    final nextMessage = '$s\n\n*Your updation is complete..*';

    ///set asked to null so next session wont identify this as registration
    user.asked = '';

    ///save user
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///let user know the updation is complete
    post(body.payLoad.sender.phone, nextMessage);

    ///send further option
    ///wait a bit
    await Future.delayed(const Duration(milliseconds: 500));
    sendOptions(body, user);
  }

  ///continue registration as the user is in registration process
  Future<void> userIncomplete(Body body, User user) async {
    if (user.asked == User.NAME) {
      final text = body.payLoad.dataPayload.text;
      final name = getNameFromText(text);

      ///we asked name in the last step, try to process name from the reply
      if (name.isEmpty) {
        const nextMessage = 'tell me your name within two words..';
        sorryIDidntUnderstand(nextMessage, body, user);
      } else {
        user.name = name;
        final nextMessage = 'Okay, we will use *${user.name}* as your name.';

        ///check if its registration or updation
        if (user.isNotComplete()) {
          ///this is registration proceed with next step
          askAddress(nextMessage, body, user);
        } else {
          ///this is updation tell updation complete
          updationDone(nextMessage, body, user);
        }
      }
    } else if (user.asked == User.ADDRESS) {
      final text = body.payLoad.dataPayload.text;
      final address = getAddressFromText(text);
      if (address.first.length < 11) {
        addressIsShort(body, user);
      } else if (address.length == 2) {
        ///set address with PIN sent
        user.address = address.first;
        user.pin = address.last;

        ///prepare next message
        final nextMessage =
            'Okay, we will use\n*${address.first}*\n*PIN - ${address.last}*\nas your mealbox delivery address..';

        ///check if is this registration or updation
        if (user.isNotComplete()) {
          ///this is registration
          await askLocation(nextMessage, body, user);
        } else {
          ///it is updation dont ask next step, inform updation complete
          updationDone(nextMessage, body, user);
        }
      } else if (address.length == 1) {
        ///set only address as only address has been sent and ask for PIN
        user.address = address.first;

        ///prepare next message
        final nextMessage =
            'Okay, we will use\n*${address.first}* as your address.';

        ///check if this is updation or registration
        if (user.isNotComplete()) {
          ///this is registration proceed with next step
          askPIN(nextMessage, body, user);
        } else {
          ///this is updation
          updationDone(nextMessage, body, user);
        }
      }
    } else if (user.asked == User.PIN) {
      final text = body.payLoad.dataPayload.text;
      final pin = getPinFromText(text);
      if (pin.isNotEmpty) {
        user.pin = pin;

        ///prepare next message
        final nextMessage = 'Okay, we will use the PIN - *$pin.*';

        ///check if is this registration or updation
        if (user.isNotComplete()) {
          ///this is registration proceed with next step
          await askLocation(nextMessage, body, user);
        } else {
          ///it is updation, inform updation complete
          updationDone(nextMessage, body, user);
        }
      } else {
        const nextMessage = 'I Didn\'t get the PIN you have sent.';
        askPIN(nextMessage, body, user);
      }
    } else if (user.asked == User.LOCATION) {
      ///process only if it is location message
      if (body.payLoad.type == Payload.LOCATION) {
        ///parse user loaction using the location message they have sent
        final latitude = body.payLoad.dataPayload.latitude;
        final longitude = body.payLoad.dataPayload.longitude;

        ///post the latLng to google to check the PIN
        final pin = await postForGeocode('$latitude,$longitude');

        ///compare the pin from google with the one they've provided
        if (pin == user.pin) {
          ///check if its updation or registration
          if (user.isNotComplete()) {
            ///its registration
            ///save the location
            user.location = '$latitude,$longitude';
            registrationComplete(body, user);
          } else {
            ///its updation
            ///save the location
            ///prepare next message
            const nextMessage = 'I have saved your location..';
            user.location = '$latitude,$longitude';
            updationDone(nextMessage, body, user);
          }
        } else {
          locationDontMatchAddress(body, user);
        }
      } else {
        ///we were expecting a location but the user sent some thing else
        ///prepare reply
        const String nextMessage = 'I\'m expecting a location..';
        sorryIDidntUnderstand(nextMessage, body, user);
      }
    } else if (user.asked == User.PHONE) {
      final String phone =
          getUserPhoneNumberFromText(body.payLoad.dataPayload.text);
      if (phone.isNotEmpty) {
        ///phone number parsed
        user.phone = phone;

        ///phone number updation success
        phoneUpdated(body, user);
      } else {
        ///unable to understand the last message
        const String nextMessage =
            'I was unable to find the 10 digit phone number..';
        sorryIDidntUnderstand(nextMessage, body, user);
      }
    }
  }

  ///the user sent address is short
  void addressIsShort(Body body, User user) async {
    const String nextMessage = 'I need reasonably complete address please';

    sorryIDidntUnderstand(nextMessage, body, user);
  }

  ///new phone number succesfully updated
  void phoneUpdated(Body body, User user) async {
    ///prepare the next message
    final String nextMessage =
        'Okay we will use *${user.phone}* as your contact number'
        '\nbut you should know that we\'ll use your number ${body.payLoad.sender.phone} as backup..';

    ///save the session and deets
    user.asked = '';
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send reply
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///all the user detail has been set,proceed to order
  void registrationComplete(Body body, User user) async {
    const nextMessage = '*You have successfully set up a account with us*';

    ///save session and phone number
    user.phone = body.payLoad.sender.phone;
    user.asked = '';
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send message teeling further instruction
    post(body.payLoad.sender.phone, nextMessage);

    ///send options message
    ///wait a bit
    await Future.delayed(const Duration(milliseconds: 500));
    sendOptions(body, user);
  }

  void sendOptions(Body body, User user) {
    final nextMessage = '\nNow,'
        '\n• To order food just send *${Keywords.ORDER}*'
        '\n• To see the full account options send *${Keywords.OPTIONS}*'
        '\n\nHave a happy meal :)';

    ///post the options
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///send reply to [Keywords.OPTIONS] keyword, include all the available options
  void sendFullOptions(Body body, User user) {
    final nextMessage =
        '\n• To order food just send *${Keywords.ORDER.toLowerCase()}*'
        '\n• To see the account details send *${Keywords.ACCOUNT.toLowerCase()}*'
        '\n• To see the details about next meal send *${Keywords.NEXT_MEAL.toLowerCase()}*'
        '\n• To change all the account details send *${Keywords.CHANGE_DETAILS.toLowerCase()}*'
        '\n• To change name send *${Keywords.CHANGE_NAME.toLowerCase()}*'
        '\n• To change address send *${Keywords.CHANGE_ADDRESS.toLowerCase()}*'
        '\n• To change location send *${Keywords.CHANGE_LOCATION.toLowerCase()}*'
        '\n• To Add alternative contact num send *${Keywords.CHANGE_NUMBER.toLowerCase()}*'
        '\n\nHave a happy meal :)';

    ///post the options
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///user location doesnt match with the address provided
  void locationDontMatchAddress(Body body, User user) async {
    const nextMessage =
        'The location you have sent doesn\'t match the your address,'
        ' two possible scenerios\n_·you didnt send the precise location_'
        '\n_·the PIN code in the address is wrong_\n\nto set new address or '
        'PIN send\n*RESET ADDRESS*\nor send your updated location';

    ///save user deets for next session
    user.asked = User.LOCATION;
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///we accepted user's address and pin, now do a request for location
  Future<void> askLocation(String s, Body body, User user) async {
    final String nextMessage =
        '$s\n\nI need your location so our delivery will be easier and faster\n*Send me your Location..*';

    ///save user deets for next session
    user.asked = User.LOCATION;
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///after asking the address,as the pincode is missing ask for pincode
  void askPIN(String s, Body body, User user) async {
    ///might look into making conversation more random
    final pins = User.bulletPins.join('\n');
    final String nextMessage =
        '$s\n\nYou\'ve missed the PIN code, we serve only in these PIN codes for now\n$pins\n\n*Tell me your PIN code..*';

    ///save user deets for next session
    user.asked = User.PIN;
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

    ///send message
    post(body.payLoad.sender.phone, nextMessage);
  }

  ///after asking the name ask for address in one go
  void askAddress(String s, Body body, User user) async {
    final String nextMessage =
        '$s\n\nFor delivery purposes,\n*Tell me your complete address in one message..*';

    ///save user deets for next session
    user.asked = User.ADDRESS;
    await _commands.hmset(body.payLoad.sender.phone, hash: user.map);

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
    final client = http.Client();
    final response = await client.post(
      messageEnd,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        'apikey': gsk
      },
      body: {
        'channel': 'whatsapp',
        'source': myNumber,
        'destination': toNumber,
        'src.name': business,
        'message': json.encode(
          {
            'isHSM': 'false',
            'type': 'text',
            'text': text,
          },
        )
      },
    );

    print(response.body);
  }

  ///this request gets google reverse geocoding for the provided latLong
  final String _gk = 'AIzaSyCj8Rpr-khGa_vmJ3cviQ1IlprhNVKUOQQ';
  final String _geocodeEnd =
      'https://maps.googleapis.com/maps/api/geocode/json?';

  Future<String> postForGeocode(String latLongSeperatedByComma) async {
    final url = '${_geocodeEnd}latlng=${latLongSeperatedByComma}&key=$_gk';
    final client = http.Client();
    final response = await client.get(url);
    final Map<String, dynamic> map =
        Map.castFrom(json.decode(response.body) as Map);

    ///this encodes full fledged valid address from google using the users location, should consider using this
    try {
      final String address =
          Map.castFrom(List.castFrom(map['results'] as List)?.first as Map)[
              'formatted_address'] as String;
      return getPinFromText(address);
    } catch (e) {
      print(e);
      return '';
    }
  }
}
