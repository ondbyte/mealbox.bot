class GSBody {
  GSBody(Map<String, dynamic> dynamicBody) {
    _type = getValue(dynamicBody, 'type');
    _payload = Payload(dynamicPayload: getValueDynamic(dynamicBody, 'payload'));
  }

  static String MESSAGE = 'message',
      USER_EVENT = 'user-event',
      MESSAGE_EVENT = 'message-event';

  String _type;
  Payload _payload;

  String get type => _type;

  Payload get payLoad => _payload;

  @override
  String toString() {
    return '{type:$type, payload:${payLoad.toString()}}';
  }
}

class Payload {
  Payload({Map<String, dynamic> dynamicPayload}) {
    _id = getValue(dynamicPayload, 'id');

    _source = getValue(dynamicPayload, 'source');
    _type = getValue(dynamicPayload, 'type');
    _dataPayload =
        DataPayload(dynamicData: getValueDynamic(dynamicPayload, 'payload'));
    _sender = Sender(dynamicSender: getValueDynamic(dynamicPayload, 'sender'));
  }

  String _id, _source, _type;
  DataPayload _dataPayload;
  Sender _sender;

  String get id => _id;
  String get source => _source;
  String get type => _type;
  DataPayload get dataPayload => _dataPayload;
  Sender get sender => _sender;

  @override
  String toString() {
    return '{id: $id, source:$source, type:$type, dataPayload:${dataPayload.toString()}, sender:${sender.toString()}}';
  }
}

class DataPayload {
  DataPayload({Map<String, dynamic> dynamicData}) {
    if (dynamicData != null) {
      _text = getValue(dynamicData, 'text');
      _caption = getValue(dynamicData, 'caption');
      _url = getValue(dynamicData, 'url');
      _latitude = getValue(dynamicData, 'latitude');
      _longitude = getValue(dynamicData, 'longitude');
    }
  }
  String _text;
  String _caption;
  String _url;
  String _longitude;
  String _latitude;

  String get text => _text;

  String get caption => _caption;

  String get url => _url;

  String get longitude => _longitude;

  String get latitude => _latitude;

  @override
  String toString() {
    return '{text:$text, caption:$caption, url:$url}';
  }
}

class Sender {
  Sender({Map<String, dynamic> dynamicSender}) {
    if (dynamicSender != null) {
      _phone = getValue(dynamicSender, 'phone');
      _name = getValue(dynamicSender, 'name');
    }
  }
  String _phone, _name;

  String get phone => _phone;

  String get name => _name;

  @override
  String toString() {
    return '{phone:$phone, name:$name}';
  }
}

String getValue(Map<dynamic, dynamic> map, String key) {
  assert(map != null);
  if (map.containsKey(key)) {
    return map[key].toString();
  }
  return null;
}

Map<String, dynamic> getValueDynamic(Map<dynamic, dynamic> map, String key) {
  assert(map != null);
  if (map.containsKey(key)) {
    return Map.castFrom(map[key] as Map);
  }
  return null;
}

class MBody {
  MBody(Map<String, dynamic> map) {
    updateType = getValue(map, 'type');
    if (updateType  == MBody.MESSAGE) {
      final Map<String, dynamic> message = getValueDynamic(map, 'message');
      messageType = getValue(message, 'type');
      if (messageType == MBody.TEXT) {
        text = getValue(message, 'text');
      } else if(messageType == MBody.LOCATION){
        final String s = getValue(message, 'payload');
        final List<String> ll = s.split(',');
        latitude = ll.first;
        longitude = ll.last;
      }
    }

    if (map.containsKey('user')) {
      final Map<String, dynamic> user = getValueDynamic(map, 'user');
      if(user.containsKey('phone')){
        phone = getValue(user, 'phone');
      }
    }
  }
  static String TEXT = 'text', LOCATION = 'location';
  static String MESSAGE = 'message';
  String updateType, messageType, text,phone,latitude,longitude;
}

class Body {
  Body(Map<String, dynamic> map, API type) {
    _api = type;
    if (type == API.gupshup) {
      asignGupshupParameters(map);
    } else if (type == API.maytapi) {
      assignMaytapiParameters(map);
    }
  }

  API _api;

  API get api =>_api;

  ///message types

  static String TEXT = 'text',
      IMAGE = 'image',
      AUDIO = 'audio',
      VIDEO = 'video',
      DOCUMENT = 'file',
      LOCATION = 'location',
      CONTACT = 'contact';

  String EVENT_TYPE, MESSAGE_TYPE;
  String text, phone, latitude, longitude;
  void asignGupshupParameters(Map<String, dynamic> map) {
    final GSBody gsBody = GSBody(map);
    text = gsBody.payLoad.dataPayload.text;
    phone = gsBody.payLoad.sender.phone;
    latitude = gsBody.payLoad.dataPayload.latitude;
    longitude = gsBody.payLoad.dataPayload.longitude;
    EVENT_TYPE = gsBody.type;
    MESSAGE_TYPE = gsBody.payLoad.type;
  }

  void assignMaytapiParameters(Map<String, dynamic> map) {
    final MBody mBody = MBody(map);
    text = mBody.text;
    phone = mBody.phone;
    latitude = mBody.latitude;
    longitude = mBody.longitude;
    EVENT_TYPE = mBody.updateType;
    MESSAGE_TYPE = mBody.messageType;
  }
}

enum API {
  gupshup,
  maytapi,
}
