import base64
import json
import random
from datetime import datetime

from django.conf import settings
from django.http import JsonResponse, HttpRequest
from django.utils.decorators import method_decorator
from django_ratelimit.decorators import ratelimit
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.throttling import AnonRateThrottle
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError

from backend.models import SmsCode
from backend.service import token_manager, sms_sender


class SendSMSView(APIView):
    @method_decorator(ratelimit(key='ip', rate='3/h'))
    def post(self, request):
        phone = request.data.get('phone', '')
        sms_code = SmsCode.objects.filter(phone=phone).first()
        pin = str(random.randrange(100000, 1000000))
        now_sec = datetime.utcnow().timestamp()

        if not sms_code:
            try:
                SmsCode.objects.create(phone=phone, pin=pin)
            except:
                raise ValidationError('Inavlid format')
        else:
            resend_at = int(sms_code.updated_at.timestamp() + settings.SMS_CODE_VALID_SECONDS)
            if now_sec <= resend_at and False:
                return JsonResponse({'resend_at': resend_at, 'details': ['']}, status=400)
            else:
                sms_code.pin = pin
                sms_code.save()
        try:
            sms_sender.send_sms(phone=phone, text=pin)
            resend_at = int(now_sec + settings.SMS_CODE_VALID_SECONDS)
            return Response(status=200, data={
                'resend_at': int(resend_at)
            })
        except:
            raise ValidationError('Error during sending sms')


class LoginView(APIView):

    def post(self, request):
        phone = request.data.get('phone', '')
        pin = request.data.get('pin', '')

        try:
            sms_code = SmsCode.objects.get(phone=phone)
        except SmsCode.DoesNotExist:
            raise ValidationError('Requested code does not exist')
        except:
            return Response(status=400)

        now_sec = datetime.utcnow().timestamp()
        if now_sec > (sms_code.updated_at.timestamp() + settings.SMS_CODE_VALID_SECONDS):
            raise ValidationError('Code expired')

        if sms_code.pin != pin:
            raise ValidationError('Invalid pin')

        payload = {
            'phone': phone,
            'valid_until': now_sec + settings.TOKEN_VALID_SECONDS,
        }
        sms_code.delete()
        token = token_manager.generate_token(payload)
        return Response({'token': token})


class RefreshTokenView(APIView):
    def post(self, request: HttpRequest):
        if request.user.is_authenticated:
            payload = {
                'phone': str(request.user.pk),
                'valid_until': datetime.utcnow().timestamp() + settings.TOKEN_VALID_SECONDS,
            }
            token = token_manager.generate_token(payload)
            return Response({'token': token})
        else:
            return Response(status=403)
