import base64
import json
import time
from datetime import datetime

from django.contrib.auth.backends import BaseBackend
from django.contrib.auth.models import User, AnonymousUser
from django.http import HttpRequest

from rest_framework.exceptions import AuthenticationFailed

from backend.models import User


class JwtAuthBackend(BaseBackend):

    def authenticate_header(self, _):
        pass

    def authenticate(self, request: HttpRequest, username=None, password=None):
        header = request.headers.get('Authorization')
        if not header:
            return
        tokens = header.split()
        if len(tokens) != 2 or tokens[0] != 'Bearer':
            raise AuthenticationFailed('Invalid token format')

        token = base64.b64decode(tokens[1]).decode()
        payload: dict = json.loads(token)
        phone: str = payload.get('phone', '')
        valid_until: int = payload.get('valid_until', 0)

        if datetime.utcnow().timestamp() > valid_until:
            raise AuthenticationFailed('Token expired')

        try:
            user = User.objects.get(phone=phone)
        except User.DoesNotExist:
            user = User(username=phone, phone=phone)
            user.save()
        return user, None

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None
