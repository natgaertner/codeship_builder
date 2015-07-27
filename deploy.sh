#!/bin/bash
SERVICE_NAME=$1
SERVICE_TASK_DEFINITION=$(aws ecs describe-services  --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME} | python -c 'import sys, json; print re.match(r"arn:aws:ecs:.*:\d+:task-definition/(?P<task_name>.*):\d+",json.load(sys.stdin)["services"][0][taskDefinition])')
aws ecs describe-task-definition --task-definition ${SERVICE_TASK_DEFINITION} | python -c "import sys,json; print json.dumps({'family':'${SERVICE_TASK_DEFINITION}', 'containerDefinitions':json.load(sys.stdin)['taskDefinition']['containerDefinitions']})" > tmp.json
aws ecs register-task-definition --cli-input-json file://tmp.json
rm tmp.json
aws ecs update-service --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME} --task-definition ${SERVICE_TASK_DEFINITION}
aws ecs wait services-stable --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME}
