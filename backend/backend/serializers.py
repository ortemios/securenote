from rest_framework import serializers

from backend.models import Note


class NoteSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)

    class Meta:
        model = Note
        fields = ['id', 'title', 'content']
