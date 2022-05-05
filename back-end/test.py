#!/usr/bin/env python

import requests
import asyncio
from websockets import connect

def login(client_id: str, username: str, password: str):
    payload = {
        "client_id": client_id,
        "grant_type": "password",
        "username": username,
        "password": password,
        "scope": "notification.flight-planning.read notification.geoawareness.read",
    }
    resp = requests.post("https://www.ucis.ssghosting.net/auth/realms/UCIS/protocol/openid-connect/token", data=payload)
    if resp.status_code == 200:
        return resp.json()["access_token"]
    return None

async def process(message):
    print(message)

async def main():
    token=login("d7d08988-97ba-44af-a7e1-afab0524510b", "cconan", "wac_2022")
    headers = {
        "Authorization":"Bearer " + token
    }
    print(token)
    async with connect("wss://wss.ucis.ssghosting.net/dops", extra_headers=headers) as websocket:
        async for message in websocket:
            await process(message)

asyncio.run(main())