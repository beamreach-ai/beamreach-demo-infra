import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    logger.info("Received stream batch: %s", json.dumps(event))
    return {"records": len(event.get("Records", []))}
