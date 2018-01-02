# -*- coding: utf-8 -*-

from base64 import b32encode
import hashlib
from random import Random


def RandomNumStr(randomlength=8):
    chars = '0123456789'
    length = len(chars) - 1
    random = Random()
    s = str(chars[random.randint(1, length)])
    for _ in range(randomlength - 1):
        s += chars[random.randint(0, length)]
    return s
    
def RandomStr(randomlength=8):
    chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    length = len(chars) - 1
    random = Random()
    s = str(chars[random.randint(1, length)])
    for _ in range(randomlength - 1):
        s += chars[random.randint(0, length)]
    return s

def RandomLowerStr(randomlength=8):
    chars = 'abcdefghijklmnopqrstuvwxyz'
    length = len(chars) - 1
    random = Random()
    s = str(chars[random.randint(1, length)])
    for _ in range(randomlength - 1):
        s += chars[random.randint(0, length)]
    return s

def Sha256sum(text):
    sh = hashlib.sha256()
    sh.update(text)

    return b32encode(sh.digest()[:20])