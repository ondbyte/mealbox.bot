//check is this a order string
bool isOrder(String s) {
  final String text = s.toLowerCase();

  if (text.contains('order')) {
    return true;
  }
  return false;
}

class Keywords {
  ///the whatsapp user keywords/commands
  static const String CHANGE_ADDRESS = 'CHANGE ADDRESS',
      CHANGE_NAME = 'CHANGE NAME',
      ADD_NUMBER = 'ADD NUMBER',
      CHANGE_LOCATION = 'CHANGE LOCATION',
      ORDER = 'ORDER',
      NEXT_MEAL = 'NEXT MEAL',
      ACCOUNT = 'ACCOUNT',
      CHANGE_DETAILS = 'CHANGE DETAILS',
      OPTIONS = 'OPTIONS',
      YES = 'YES';
  static List<String> keyWords = [
    CHANGE_ADDRESS,
    CHANGE_LOCATION,
    CHANGE_NAME,
    ADD_NUMBER,
    ORDER,
    NEXT_MEAL,
    ACCOUNT,
    CHANGE_DETAILS,
    OPTIONS,
    YES,
  ];
}

String getKeyWordFromText(String ss) {
  if (ss == null) {
    return '';
  }
  final s = ss.trim().toUpperCase();
  return Keywords.keyWords.firstWhere((kw) {
    return kw == s;
  }, orElse: () {
    return '';
  });
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
  } else {
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
    keyword = map[KEYWORD];
    phone = map[PHONE];
  }
  String asked, keyword,phone;
  String name, address, location, pin;

  bool isComplete() {
    return name.isNotEmpty &&
        address.isNotEmpty &&
        pin.isNotEmpty &&
        location.isNotEmpty&&
        phone.isEmpty;
  }

  bool isNotComplete() => !isComplete();

  static List<String> pins = [
    '570009',
    '570022',
    '570023',
    '570024',
    '570025',
    '570026'
  ];

  static Iterable<String> bulletPins = pins.map((p) {
    return '• $p';
  });

  static String NAME = 'name',
      ADDRESS = 'address',
      LOCATION = 'location',
      PIN = 'pin',
      ASKED = 'asked',
      PHONE = 'phone',
      KEYWORD = 'keyword';

  static Map<String, String> userMap = {
    ASKED: '',
    NAME: '',
    ADDRESS: '',
    LOCATION: '',
    PIN: '',
    PHONE: '',
    KEYWORD: '',
  };

  Map<String, String> get map => {
        ASKED: asked,
        NAME: name,
        ADDRESS: address,
        LOCATION: location,
        PIN: pin,
        PHONE: phone,
        KEYWORD: keyword,
      };
}
