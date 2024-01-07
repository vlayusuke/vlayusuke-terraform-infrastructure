import os
import json
from urllib import request

hook_url = os.getenv("hook_url")

headers = {
    "Content-Type": "application/json"
}


def lambda_handler(event, context):
    for record in event['Records']:
        if not "Sns" in record.keys():
            return

        params = {
            'text': record['Sns']['Message']
        }

        req = request.Request(hook_url, json.dump(
            params).encode(), headers, method='POST')
        with request.urlopen(req) as res:
            content = res.read()
            print(content)

    return
