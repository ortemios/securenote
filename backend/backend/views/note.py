from django.http import HttpResponse, HttpRequest
import json


def index(request: HttpRequest):
    if request.method == 'POST':
        #id = request.body['id']

        return HttpResponse(f'Post! {str(request.body)}')
    else:
        return HttpResponse(f'Get! {request.body}')
