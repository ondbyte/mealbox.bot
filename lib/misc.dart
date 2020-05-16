//check is this a order string
import 'dart:math';

bool isOrder(String s) {
  final String text = s.toLowerCase();

  if (text.contains('order')) {
    return true;
  }
  return false;
}

bool isBreakFastTime(String s) {
  final String ss = s.trim().replaceAll(' ', '').toLowerCase();

  return breakFastTimings().split(',').any((t) {
    return t == ss;
  });
}

bool isLunchTime(String s) {
  final String ss = s.trim().replaceAll(' ', '').toLowerCase();

  return lunchTimings().split(',').any((t) {
    return t == ss;
  });
}

bool isDinnerTime(String s) {
  final String ss = s.trim().replaceAll(' ', '').toLowerCase();

  return dinnerTimings().split(',').any((t) {
    return t == ss;
  });
}

int get24HRFormat(String s) {
  int digit;
  if (s.length == 4) {
    digit = int.tryParse(s[0] + s[1]);
  } else {
    digit = int.tryParse(s[0]);
  }
  if (digit == null) {
    throw Exception('thisShouldHaveNeverHappened');
  } else {
    if (s.contains('pm')) {
      if (digit != 12) {
        digit = digit + 12;
      }
    }
  }
  return digit;
}

DateTime getOrderingTime(String date, String text) {
  final String ss = text.trim().replaceAll(' ', '').toLowerCase();
  final int time = get24HRFormat(ss);
  if (time == null) {
    return null;
  }

  final DateTime dt = DateTime.parse(date);
  return DateTime(dt.year, dt.month, dt.day, time);
}

bool isToday(DateTime dt) {
  final DateTime today = DateTime.now();
  if (dt.year == today.year && dt.month == today.month && dt.day == today.day) {
    return true;
  }
  return false;
}

String formatDateForConvo(DateTime dt) {
  final DateTime today = DateTime.now();
  final DateTime tomo = DateTime(today.year, today.month, today.day + 1);
  if (dt.year == today.year && dt.month == today.month && dt.day == today.day) {
    return 'Today';
  } else if (dt.year == tomo.year &&
      dt.month == tomo.month &&
      dt.day == tomo.day) {
    return 'Tomorrow';
  }
  return [dt.day, dt.month, dt.year].join('/');
}

DateTime parseDate(String s) {
  final tmp = s.trim().replaceAll(' ', '');

  final DateTime dt = DateTime.now();

  if (s.endsWith('today') && s.length < 10) {
    return DateTime(dt.year, dt.month, dt.day);
  } else if (s.endsWith('tomorrow') && s.length < 10) {
    return DateTime(dt.year, dt.month, dt.day + 1);
  }
  final List<int> date = [];
  if (tmp.contains('/')) {
    tmp.split('/').forEach((d) {
      date.add(int.tryParse(d));
    });
  } else if (tmp.contains('-')) {
    tmp.split('-').forEach((d) {
      date.add(int.tryParse(d));
    });
  }
  if (date.any((d) {
    return d == null;
  })) {
    return null;
  } else {
    return DateTime(date[2], date[1], date[0]);
  }
}

String greeting() {
  final DateTime dt = DateTime.now();
  if (dt.isAfter(DateTime(dt.year, dt.month, dt.day, 2))) {
    if (dt.isBefore(DateTime(dt.year, dt.month, dt.day, 12))) {
      return 'Morning';
    }
    if (dt.isBefore(DateTime(dt.year, dt.month, dt.day, 15))) {
      return 'Afternoon';
    }
    if (dt.isBefore(DateTime(dt.year, dt.month, dt.day, 22))) {
      return 'Evening';
    }
  }
  return 'Night';
}

bool isGreeting(String s) {
  final String tmp = s.trim().toLowerCase().replaceAll(' ', '');
  if (tmp.endsWith('hello')) {
    return true;
  }
  if (tmp.endsWith('hi')) {
    return true;
  }
  if (tmp.endsWith('goodmorning')) {
    return true;
  }
  if (tmp.endsWith('goodafternoon')) {
    return true;
  }
  if (tmp.endsWith('goodnight')) {
    return true;
  }
  return false;
}

String getAvailableOrders({bool isToday = true}) {
  String s = '';
  final DateTime dt = DateTime.now();
  if (!isToday || dt.isBefore(DateTime(dt.year, dt.month, dt.day, 10))) {
    s = '\n*${Keywords.BREAKFAST.toLowerCase()}*';
  }
  if (!isToday || dt.isBefore(DateTime(dt.year, dt.month, dt.day, 14))) {
    s = '$s\n*${Keywords.LUNCH.toLowerCase()}*';
  }
  if (!isToday || dt.isBefore(DateTime(dt.year, dt.month, dt.day, 21))) {
    s = '$s\n*${Keywords.DINNER.toLowerCase()}*';
  }
  return s;
}

String breakFastTimings() {
  return '8am,9am,10am';
}

String lunchTimings() {
  return '12pm,1pm,2pm';
}

String dinnerTimings() {
  return '7pm,8pm,9pm';
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
    default:
      {
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
      YES = 'YES',
      BREAKFAST = 'BREAKFAST',
      LUNCH = 'LUNCH',
      DINNER = 'DINNER',
      WHEN = 'WHEN',
      TIME_FIXED = 'TIME_FIXED';
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
    BREAKFAST,
    LUNCH,
    DINNER,
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
    order_date = map[ORDER_DATE];
  }
  String asked, keyword, phone, order_date;
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
      KEYWORD = 'keyword',
      ORDER_DATE = 'order_date';

  static Map<String, String> userMap = {
    ASKED: '',
    NAME: '',
    ADDRESS: '',
    LOCATION: '',
    PIN: '',
    PHONE: '',
    KEYWORD: '',
    ORDER_DATE: '',
  };

  Map<String, String> get map => {
        ASKED: asked,
        NAME: name,
        ADDRESS: address,
        LOCATION: location,
        PIN: pin,
        PHONE: phone,
        KEYWORD: keyword,
        ORDER_DATE:order_date,
      };
}
