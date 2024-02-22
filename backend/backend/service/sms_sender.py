import json
import requests
import backend.settings as settings


def send_sms(phone: str, text: str):
    url = (
        f'https://{settings.SMSAERO_EMAIL}:{settings.SMSAERO_API_KEY}'
        f'@gate.smsaero.ru/v2/sms/send?'
        f'number=7{phone}&'
        f'text={text}&'
        f'sign={settings.SMSAERO_SIGN}'
    )
    #resp = requests.get(url)
    #data = json.loads(resp.content)
    #print('Response:', data)
