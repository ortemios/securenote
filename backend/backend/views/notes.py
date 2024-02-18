from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from backend.models import Note
from backend.serializers import NoteSerializer


# /notes/id GET, PATCH|PUT, DELETE
# /notes/   GET, POST


class NotesView(ModelViewSet):
    queryset = Note.objects.all()
    serializer_class = NoteSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return super().get_queryset().filter(user_id=self.request.user.pk)

    def create(self, request: Request, *args, **kwargs):
        serializer = NoteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        note = Note(**serializer.validated_data)
        note.user = request.user
        note.save()
        return Response(
            status=201,
            data=NoteSerializer(instance=note).data,
        )

    def list(self, request, *args, **kwargs):
        response = super().list(request, *args, **kwargs)
        response.data = {"items": response.data}
        return response
