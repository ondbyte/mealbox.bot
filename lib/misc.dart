//check is this a order string
bool isOrder(String s) {
  String text = s.toLowerCase();

  if (text.contains('order')) {
    return true;
  }
}

List<String> getAddressFromText(String s) {
  final intRegex = RegExp("(\\d{6})");
  final pin = intRegex.allMatches(s).map((m) => m.group(0));
  if (pin.isEmpty) {
    return [s.trim()];
  }
  if (pin.length == 1 && allowedPINs(pin.first)) {
    return [s.replaceAll(pin.first, '').trim(), pin.first];
  }
  pin.forEach((pin) {
    s = s.replaceAll(pin, '');
  });
  return [s.trim()];
}

///check the PIN of the address comes in the serviceable area
bool allowedPINs(String p) {
  return p.startsWith('57');
}

String getPinFromText(String s) {
  final intRegex = RegExp("(\\d{6})");
  final pin = intRegex.allMatches(s).map((m) => m.group(0));
  if (pin.isEmpty) {
    return '';
  } else{
    return pin.first;
  }
}

String getNameFromText(String ss) {
  var s = ss;
  s = s.toLowerCase();
  s = s.trim();
  if (s.indexOf('my') == 0) {
    s = s.replaceFirst('my', '');
  }
  s = ' $s';
  s = s.replaceAll(' name ', ' ');
  s = s.replaceAll(' is ', ' ');
  s = s.trim();
  final List<String> list = s.split(' ');
  list.removeWhere((word) {
    return word.isEmpty;
  });
  String name;
  if (list.length == 1) {
    name = list.first;
  } else if (list.length == 2) {
    name = '${list.first} ${list.last}';
  }
  if (list.length > 2) {
    name = '';
  }
  return name.trim();
}

bool checkisOk(String ss) {
  final s = ss.toLowerCase().trim();

  if (s.length < 6) {
    if (s.contains('ok')) {
      return true;
    }
    if (s.contains('okay')) {
      return true;
    }
    if (s.contains('yes')) {
      return true;
    }
  }
  return false;
}

class User {
  User(Map<String, String> map) {
    asked = map[ASKED];
    name = map[NAME];
    address = map[ADDRESS];
    location = map[LOCATION];
    pin = map[PIN];
  }
  String asked;
  String name, address, location, pin;

  static List<String> pins = [
    '570009',
    '570022',
    '570023',
    '570024',
    '570025',
    '570026'
  ];
  static String NAME = 'name',
      ADDRESS = 'address',
      LOCATION = 'location',
      PIN = 'pin',
      ASKED = 'asked';
  static Map<String, String> userMap = {
    ASKED: '',
    NAME: '',
    ADDRESS: '',
    LOCATION: '',
    PIN: '',
  };

  Map<String, String> get map => {
        ASKED: asked,
        NAME: name,
        ADDRESS: address,
        LOCATION: location,
        PIN: pin,
      };
}
