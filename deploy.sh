#!/bin/bash
set -e
set -o pipefail
SERVICE_NAME=$1
ECS_CLUSTER=$2
SERVICE_TASK_DEFINITION=$(aws ecs describe-services  --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME} | python -c 'import sys, re, json; print re.match(r"arn:aws:ecs:.*:\d+:task-definition/(?P<task_name>.*):\d+",json.load(sys.stdin)["services"][0]["taskDefinition"]).group("task_name")')
echo $SERVICE_TASK_DEFINITION
aws ecs describe-task-definition --task-definition ${SERVICE_TASK_DEFINITION} | python -c "import sys,json; d = json.load(sys.stdin)['taskDefinition']; d.pop('status');d.pop('taskDefinitionArn');d.pop('revision');print json.dumps(d)" > tmp.json
echo 'registering new task'
aws ecs register-task-definition --cli-input-json file://tmp.json
rm tmp.json
echo 'updating service'
aws ecs update-service --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME} --task-definition ${SERVICE_TASK_DEFINITION}
echo "waiting for service ${SERVICE_NAME} to stabilize on cluster ${ECS_CLUSTER:-default}"
aws ecs wait services-stable --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME}
