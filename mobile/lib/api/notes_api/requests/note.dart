import 'package:secure_note/api/api.dart';
import 'package:secure_note/api/notes_api/dto/note_dto_short.dart';

import '../dto/note_dto_full.dart';

extension NoteRequests on NotesApi {
  Future<NoteGetAllResponse> noteGetAll() => get(
        path: 'note/',
        params: {},
        mapper: (json) => NoteGetAllResponse(json),
      );

  Future<NoteGetResponse> noteGet({required int id}) => get(
        path: 'note/$id',
        params: {},
        mapper: (json) => NoteGetResponse(json),
      );

  Future<NotePostResponse> notePost({
    int? id,
    required String title,
    required String content,
  }) =>
      post(
        path: 'note/$id',
        params: {},
        body: {
          if (id != null) 'id': id,
          'title': title,
          'content': content,
        },
        mapper: (json) => NotePostResponse(json),
      );

  Future<NoteDeleteResponse> noteDelete({required int id}) => delete(
        path: 'note/$id',
        params: {},
        mapper: (json) => NoteDeleteResponse(json),
      );
}

class NoteGetAllResponse extends ApiResponse {
  final List<NoteDTOShort> items;

  NoteGetAllResponse(JsonNode json)
      : items = json.optObjectList(
          "items",
          (item) => NoteDTOShort(item),
        ),
        super(json);
}

class NoteGetResponse extends ApiResponse {
  final NoteDTOFull item;

  NoteGetResponse(JsonNode json)
      : item = json.mapObject(
          "item",
          (json) => NoteDTOFull(json),
        ),
        super(json);
}

class NotePostResponse extends ApiResponse {
  final NoteDTOFull item;

  NotePostResponse(JsonNode json)
      : item = json.mapObject(
          "item",
          (json) => NoteDTOFull(json),
        ),
        super(json);
}

class NoteDeleteResponse extends ApiResponse {
  NoteDeleteResponse(JsonNode json) : super(json);
}
