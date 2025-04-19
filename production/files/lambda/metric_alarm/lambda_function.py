import json
import os
from urllib import request

hook_url = os.environ['hook_url']
region = os.environ['target_region']

headers = {
    'Content-Type': 'application/json'
}


def lambda_handler(event, context):
    data = json.loads(event['Records'])

    for row in data:
        try:
            alarm_name = row['Sns']['Message']['AlarmName']
            alarm_url = "https://" + region + ".console.aws.amazon.com/cloudwatch/home?region=" + region + "#alarm:alarmV2:alarm/" + alarm_name + "?"

            message = {
                'text': "<!here>¥nCloudWatch Metric Alarm¥n" + alarm_url,
                'attachments': [
                    {
                        'title': row['Sns']['Subject'],
                        'color': '#ff9a17'
                    }
                ]
            }

            req = request.Request(hook_url, json.dumps(message).encode('utf-8'), headers, method='POST')

            with request.urlopen(req) as res:
                content = res.read()
                print(content)

        except:
            pass
