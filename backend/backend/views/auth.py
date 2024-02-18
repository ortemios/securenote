import base64
import json
import random
from datetime import datetime

from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError

from backend.models import SmsCode


class SendSMSView(APIView):
    def post(self, request):
        phone = request.data.get('phone', '')
        sms_code = SmsCode.objects.filter(phone=phone).first()
        pin = str(random.randrange(100000, 1000000))

        if not sms_code:
            SmsCode.objects.create(phone=phone, pin=pin)
        elif datetime.utcnow().timestamp() <= (sms_code.updated_at.timestamp() + settings.SMS_CODE_VALID_SECONDS):
            raise ValidationError(detail='Code is already sent, wait a bit')
        else:
            sms_code.pin = pin
            sms_code.save()

        return Response(status=200)


class LoginView(APIView):
    def post(self, request):
        phone = request.data.get('phone', '')
        pin = request.data.get('pin', '')

        try:
            sms_code = SmsCode.objects.get(phone=phone)
        except SmsCode.DoesNotExist:
            raise ValidationError('Requested code does not exist')

        now_sec = datetime.utcnow().timestamp()
        if now_sec > (sms_code.updated_at.timestamp() + settings.SMS_CODE_VALID_SECONDS):
            raise ValidationError('Code expired')

        if sms_code.pin != pin:
            raise ValidationError('Invalid pin')

        payload = {
            'phone': phone,
            'valid_until': now_sec + settings.TOKEN_VALID_SECONDS,
        }
        token = base64.b64encode(json.dumps(payload).encode()).decode()
        return Response({'token': token})


class RefreshTokenView(APIView):
    def post(self, request):
        pass
