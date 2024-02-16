import 'package:secure_note/api/api.dart';

class NoteDTOShort {
  final int id;
  final String title;

  NoteDTOShort(JsonNode json)
      : id = json.optInt("id"),
        title = json.optString("title");
}
