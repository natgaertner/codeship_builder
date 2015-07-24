#!/bin/bash
SERVICE_NAME=$1
SERVICE_TASK_DEFINITION=$2
aws ecs describe-task-definition --task-definition ${SERVICE_TASK_DEFINITION} | python -c "import sys,json; print json.dumps({'family':'${SERVICE_TASK_DEFINITION}', 'containerDefinitions':json.load(sys.stdin)['taskDefinition']['containerDefinitions']})" > tmp.json
aws ecs register-task-definition --cli-input-json file://tmp.json
rm tmp.json
aws ecs update-service --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME} --task-definition ${SERVICE_TASK_DEFINITION}
aws ecs wait services-stable --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME}
