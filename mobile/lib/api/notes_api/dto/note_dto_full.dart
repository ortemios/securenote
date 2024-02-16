import 'package:secure_note/api/api.dart';

class NoteDTOFull {
  final int id;
  final String title, content;

  NoteDTOFull(JsonNode json)
      : id = json.optInt("id"),
        title = json.optString("title"),
        content = json.optString("content");
}
