import base64
import json
import random

from backend import settings


def base64_encode(s):
    return base64.b64encode(s.encode()).decode()


def base64_decode(s):
    return base64.b64decode(s).decode()


CHUNK_SIZE = 4


def serialize(n: list[int]):
    a = None
    for i in n:
        b = i.to_bytes(CHUNK_SIZE)
        if a is None:
            a = b
        else:
            a += b
    return base64.b64encode(a).decode()


def deserialize(s: str):
    a = base64.b64decode(s)
    n = [int.from_bytes(a[i:i+CHUNK_SIZE]) for i in range(0, len(a), CHUNK_SIZE)]
    return n


def encode_key(key):
    return serialize([key[0], key[1]])


def decode_key(s: str):
    return tuple(map(int, deserialize(s)))


def gcd(a, b):
    while b != 0:
        a, b = b, a % b
    return a


def mod_inverse(a, m):
    m0, x0, x1 = m, 0, 1
    while a > 1:
        q = a // m
        m, a = a % m, m
        x0, x1 = x1 - q * x0, x0
    return x1 + m0 if x1 < 0 else x1

def is_prime(num):
    if num < 2:
        return False
    for i in range(2, int(num**0.5) + 1):
        if num % i == 0:
            return False
    return True

def generate_keypair():
    p = random.randint(100, 200)
    q = random.randint(200, 300)

    while not is_prime(p):
        p = random.randint(100, 200)
    while not is_prime(q) or q == p:
        q = random.randint(200, 300)

    n = p * q
    phi = (p - 1) * (q - 1)

    e = random.randint(2, phi - 1)
    while gcd(e, phi) != 1:
        e = random.randint(2, phi - 1)

    d = mod_inverse(e, phi)

    return ((e, n), (d, n))


def encrypt(key: str, plaintext):
    e, n = decode_key(key)
    cipher = [pow(ord(char), e, n) for char in plaintext]
    return cipher


def decrypt(key: str, ciphertext):
    d, n = decode_key(key)
    plain = [chr(pow(char, d, n)) for char in ciphertext]
    return ''.join(plain)


def generate_token(payload):
    header = json.dumps({"alg": "RSA", "typ": "JWT"})
    payload = json.dumps(payload)
    unsigned_token = base64_encode(header) + '.' + base64_encode(payload)
    signature = serialize(encrypt(settings.AUTH_TOKEN_PRIVATE_KEY, unsigned_token))
    token = f'{base64_encode(header)}.{base64_encode(payload)}.{base64_encode(signature)}'
    return token


def read_payload(token):
    try:
        header, payload, signature = token.split('.')
        signature = decrypt(settings.AUTH_TOKEN_PUBLIC_KEY, deserialize(base64_decode(signature)))
        if f'{header}.{payload}' == signature:
            return json.loads(base64_decode(payload))
        else:
            return None
    except:
        return None
