class JsonNode {
  final map = <String, dynamic>{};

  JsonNode(dynamic container) {
    if (container is Map<String, dynamic>) {
      map.addAll(container);
    } else if (container is List<dynamic>) {
      for (int i = 0; i < container.length; i++) {
        map[i.toString()] = container[i];
      }
    }
  }

  T optValue<T>(String key, T def) => map[key] is T ? map[key] : def;

  int optInt(String key, {int def = 0}) => _optInt(map[key], def);

  double optDouble(String key, {double def = 0}) => _optDouble(map[key], def);

  bool optBool(String key) => _optBool(map[key], false);

  String optString(String key, {String def = ''}) => _optString(map[key], def);

  T mapSelf<T>(T Function(JsonNode) mapper) => mapper(this);

  T mapObject<T>(String key, T Function(JsonNode) mapper) => mapper(JsonNode(optValue(key, <String, dynamic>{})));

  List<T> optList<T>(String key, T Function(dynamic) mapper) => optValue(key, List<dynamic>.empty()).map(mapper).toList();

  List<int> optIntList(String key, {int def = 0}) => optList(key, (value) => _optInt(value, def));

  List<double> optDoubleList(String key, {double def = 0}) => optList(key, (value) => _optDouble(value, def));

  List<String> optStringList(String key, {String def = ''}) => optList(key, (value) => _optString(value, def));

  List<T> optObjectList<T>(String key, T Function(JsonNode) mapper) => optList(key, (e) => mapper(JsonNode(e)));

  Map<T, V> optMap<T, V>(String key) => _optMap(key);

  Map<T, V> _optMap<T, V>(String key) {
    Map<T, V> z = {};
    final m = map[key];
    if (m is Map<dynamic, dynamic>) {
      for (final s in m.entries) {
        if (s.key is T && s.value is V) {
          z[s.key] = s.value;
        }
      }
    }
    return z;
  }

  int _optInt(dynamic value, int def) {
    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? def;
    } else {
      return def;
    }
  }

  double _optDouble(dynamic value, double def) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? def;
    } else {
      return def;
    }
  }

  bool _optBool(dynamic value, bool def) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return bool.tryParse(value, caseSensitive: false) ?? def;
    } else {
      return def;
    }
  }

  String _optString(dynamic value, String def) {
    if (value is String) {
      return value;
    } else {
      return def;
    }
  }
}
