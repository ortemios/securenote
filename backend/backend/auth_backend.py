import base64
import json
import time
from datetime import datetime

from django.contrib.auth.backends import BaseBackend
from django.contrib.auth.models import User, AnonymousUser
from django.http import HttpRequest

from rest_framework.exceptions import AuthenticationFailed

from backend.models import User
from backend.service import token_manager


class JwtAuthBackend(BaseBackend):

    def authenticate_header(self, _):
        pass

    def authenticate(self, request: HttpRequest, username=None, password=None):
        header = request.headers.get('Authorization')
        if not header:
            return
        tokens = header.split('Bearer ')
        if len(tokens) != 2:
            raise AuthenticationFailed('Invalid token format')
        payload: dict = token_manager.read_payload(tokens[1])
        if payload is None:
            raise AuthenticationFailed('Invalid token')
        phone: str = payload.get('phone', '')
        valid_until: int = payload.get('valid_until', 0)

        if datetime.utcnow().timestamp() > valid_until:
            return

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
