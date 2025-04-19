import json
import os
import zlib
import base64
from urllib import request

hook_url = os.environ['hook_url']

headers = {
    "Content-Type": "application/json"
}


def lambda_handler(event, context):
    print(event)
    data = event['awslogs']['data']
    json_str = zlib.decompress(base64.b64decode(data), 16 + zlib.MAX_WBITS).decode('utf-8')
    json_data = json.loads(json_str)

    for row in json_data['logEvents']:
        print(row)
        log_message = '''
            Log group : `{logGroup}`\nLog stream : {logStream}\n<https://ap-northeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-northeast-1#logEventViewer:group={logGroup};stream={logStream} | 詳細はここをクリック>
            ```{message}```
        '''.format(
            logGroup=str(json_data['logGroup']),
            logStream=str(json_data['logStream']),
            message=str(row['message'])
        ).strip()

        params = {
            'text': log_message
        }

        req = request.Request(hook_url, json.dumps(params).encode(), headers, method='POST')

        with request.urlopen(req) as res:
            content = res.read()
            print(content)
