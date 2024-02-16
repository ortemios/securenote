import 'package:secure_note/api/api.dart';

class UserDTO {
  final int id;

  UserDTO(JsonNode json) : id = json.optInt('id');
}
