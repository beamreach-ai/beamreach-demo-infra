import json
import os
import time
from datetime import datetime, timezone

import boto3

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
DDB_TABLE = os.environ["DDB_TABLE_NAME"]

sns = boto3.client("sns")
dynamodb = boto3.resource("dynamodb")


def handler(event, context):
    timestamp = datetime.now(timezone.utc).isoformat()
    payload = {
        "message": "demo-map heartbeat",
        "timestamp": timestamp,
        "request_id": getattr(context, "aws_request_id", "unknown"),
    }

    sns.publish(TopicArn=SNS_TOPIC_ARN, Message=json.dumps(payload))

    dynamodb.Table(DDB_TABLE).put_item(
        Item={
            "pk": f"heartbeat#{int(time.time())}",
            "sk": timestamp,
            "payload": payload,
        }
    )

    return {"status": "ok", "timestamp": timestamp}
