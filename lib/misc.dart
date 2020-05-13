//check is this a order string
import 'dart:math';

bool isOrder(String s) {
  final String text = s.toLowerCase();

  if (text.contains('order')) {
    return true;
  }
  return false;
}

Random _random = Random();
String imStill() {
  switch (_random.nextInt(4)) {
    case 0:
      {
        return 'I am still young and learning';
      }
      break;
    case 1:
      {
        return 'I am still learning';
      }
      break;
    case 2:
      {
        return 'I am still a learner';
      }
      break;
    case 3:
      {
        return 'Currently still lerning how to traverse this world';
      }
      break;
    default: {
      return 'My bad';
    }
  }
}

class Keywords {
  ///the whatsapp user keywords/commands
  static const String CHANGE_ADDRESS = 'CHANGE ADDRESS',
      CHANGE_NAME = 'CHANGE NAME',
      CHANGE_NUMBER = 'CHANGE NUMBER',
      CHANGE_LOCATION = 'CHANGE LOCATION',
      ORDER = 'ORDER',
      NEXT_MEAL = 'NEXT MEAL',
      ACCOUNT = 'ACCOUNT',
      CHANGE_DETAILS = 'CHANGE DETAILS',
      OPTIONS = 'OPTIONS',
      CANCEL = 'CANCEL',
      YES = 'YES';
  static List<String> keyWords = [
    CHANGE_ADDRESS,
    CHANGE_LOCATION,
    CHANGE_NAME,
    CHANGE_NUMBER,
    ORDER,
    NEXT_MEAL,
    ACCOUNT,
    CHANGE_DETAILS,
    OPTIONS,
    CANCEL,
    YES,
  ];
}

String get10NumberPhone(String s) {
  return s.replaceFirst('91', '');
}

String getUserPhoneNumberFromText(String ss) {
  final intRegex = RegExp("(?<![0-9])[0-9]{10,12}(?![0-9])");
  final phone = intRegex.allMatches(ss).map((m) => m.group(0));
  if (phone.isNotEmpty) {
    if (phone.first.length == 12) {
      final s = phone.first.replaceFirst('91', '');
      return s;
    } else if (phone.first.length == 10) {
      return phone.first;
    }
  }
  return '';
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
  final intRegex = RegExp("(?<![0-9])[0-9]{5,16}(?![0-9])");
  final pin = intRegex.allMatches(s).map((m) => m.group(0));
  if (pin.isEmpty) {
    return [s.trim()];
  }
  if (pin.length == 1 && allowedPINs(pin.first)) {
    if (pin.first.length != 6) {
      return [s.replaceAll(pin.first, '').trim()];
    }
    return [s.replaceAll(pin.first, '').trim(), pin.first];
  }
  pin.forEach((pin) {
    s = s.replaceAll(pin, '');
  });
  return [s.trim()];
}

///check the PIN of the address comes in the serviceable area
bool allowedPINs(String p) {
  return p.startsWith('570');
}

String getPinFromText(String s) {
  final intRegex = RegExp("(?<![0-9])[0-9]{6}(?![0-9])");
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
  String asked, keyword, phone;
  String name, address, location, pin;

  bool isComplete() {
    return name.isNotEmpty &&
        address.isNotEmpty &&
        pin.isNotEmpty &&
        location.isNotEmpty &&
        phone.isNotEmpty;
  }

  bool isNotComplete() {
    return name.isEmpty ||
        address.isEmpty ||
        pin.isEmpty ||
        location.isEmpty ||
        phone.isEmpty;
  }

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
