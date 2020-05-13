class GSBody {
  GSBody(Map<String, dynamic> dynamicBody) {
    _app = getValue(dynamicBody, 'app');
    _timeStamp = getValue(dynamicBody, 'timestamp');
    _type = getValue(dynamicBody, 'type');
    _payload = Payload(dynamicPayload: getValueDynamic(dynamicBody, 'payload'));
  }

  static String MESSAGE = 'message',
      USER_EVENT = 'user-event',
      MESSAGE_EVENT = 'message-event';

  String _app, _timeStamp, _type;
  Payload _payload;

  String get type => _type;

  String get timeStamp => _timeStamp;

  String get app => _app;

  Payload get payLoad => _payload;

  @override
  String toString() {
    return '{app: $app, timeStamp:$timeStamp, type:$type, payload:${payLoad.toString()}}';
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

  static String TEXT = 'text',
      IMAGE = 'image',
      AUDIO = 'audio',
      VIDEO = 'video',
      DOCUMENT = 'file',
      LOCATION = 'location',
      CONTACT = 'contact';
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

class Body{

  Body(Map<String,dynamic> map,API type){
    if(type==API.gupshup){
      asignGupshupParameters(map);
    } else if(type==API.maytapi){
      assignMaytapiParameters(map);
    }
  }
  static String PAYLOAD_TEXT = 'text',PAYLOAD_LOC = 'location';
  String text,payLoadType;
  void asignGupshupParameters(Map<String,dynamic> map){
    GSBody gsBody = GSBody(map);
    text = gsBody.payLoad.dataPayload.text;
    payLoadType = gsBody.payLoad.type;

  }

  void assignMaytapiParameters(Map<String,dynamic> map){

  }
}


enum API{
  gupshup,
  maytapi,
}
