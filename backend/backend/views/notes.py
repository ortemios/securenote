import json
from typing import Optional
from django.http import HttpResponse, HttpRequest, JsonResponse
from django.core import serializers

from django.views import View

from backend.models import Note


class NotesView(View):

    def get(self, request: HttpRequest):
        items = Note.objects.all()
        return JsonResponse({
            'items': list(map(_to_json, items))
        })
    
    def post(self, request: HttpRequest):
        params = json.loads(request.body)
        id = params.get('id')
        title = params.get('title', '')
        content = params.get('content', '')

        item, _ = Note.objects.get_or_create(id=id)
        item.title = title
        item.content = content
        item.save()
        return JsonResponse({
            'id': item.id
        })
    

class NotesDetailView(View):
    def get(self, request: HttpRequest, id: int):
        item = Note.objects.get(id=id)
        return JsonResponse({
            'item': _to_json(item)
        })
    
    def delete(self, request: HttpRequest, id: int):
        item = Note.objects.get(id=id)
        item.delete()
        return JsonResponse({})
    

def _to_json(item: Note):
    return {
        'id': item.id,
        'title': item.title,
        'content': item.content,
    }
