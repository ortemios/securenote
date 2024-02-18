import 'package:secure_note/api/api.dart';
import 'package:secure_note/api/notes_api/dto/note_dto_short.dart';

import '../dto/note_dto_full.dart';

extension NoteRequests on NotesApi {
  Future<NoteGetAllResponse> notesGetAll() => get(
        path: 'notes/',
        params: {},
        mapper: (json) => NoteGetAllResponse(json),
      );

  Future<NoteGetResponse> notesGet({required int id}) => get(
        path: 'notes/$id/',
        params: {},
        mapper: (json) => NoteGetResponse(json),
      );

  Future<NotesItemResponse> notesPost({
    required String title,
    required String content,
  }) =>
      post(
        path: 'notes/',
        params: {},
        body: {
          'title': title,
          'content': content,
        },
        mapper: (json) => NotesItemResponse(json),
      );

  Future<NotesItemResponse> notesPatch({
    required int id,
    required String title,
    required String content,
  }) =>
      patch(
        path: 'notes/$id/',
        params: {},
        body: {
          'id': id,
          'title': title,
          'content': content,
        },
        mapper: (json) => NotesItemResponse(json),
      );

  Future<NoteDeleteResponse> noteDelete({required int id}) => delete(
        path: 'notes/$id/',
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
      : item = json.mapSelf(
          (json) => NoteDTOFull(json),
        ),
        super(json);
}

class NotesItemResponse extends ApiResponse {
  final NoteDTOFull item;

  NotesItemResponse(JsonNode json)
      : item = json.mapSelf(
          (json) => NoteDTOFull(json),
        ),
        super(json);
}

class NoteDeleteResponse extends ApiResponse {
  NoteDeleteResponse(JsonNode json) : super(json);
}
