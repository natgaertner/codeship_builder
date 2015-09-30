#!/bin/bash
set -e
set -o pipefail
source get_resource.sh

CF_DEPLOY_CLUSTER_STACK=${CF_DEPLOY_CLUSTER_STACK:-$CF_DEPLOY_STACK}

if [ $CF_DEPLOY_CLUSTER_STACK -a $LOGICAL_CLUSTER_NAME ]
then
  ECS_CLUSTER=`get_resource $CF_BUILD_STACK $LOGICAL_CLUSTER_NAME`
else
  ECS_CLUSTER=$1
fi
echo "ECS_CLUSTER: $ECS_CLUSTER"

if [ $CF_DEPLOY_STACK -a $LOGICAL_SERVICE_NAME ]
then
  SERVICE_NAME=`get_resource $CF_BUILD_STACK $LOGICAL_SERVICE_NAME | grep -Po '(?<=service/).+'`
else
  SERVICE_NAME=$2
fi
echo "SERVICE_NAME: $SERVICE_NAME"

SERVICE_TASK_DEFINITION=`aws ecs describe-services --cluster $ECS_CLUSTER --service $SERVICE_NAME | jq -r .services[0].taskDefinition | grep -Po '(?<=task-definition/).+'`
echo "SERVICE_TASK_DEFINITION: $SERVICE_TASK_DEFINITION"

aws ecs describe-task-definition --task-definition ${SERVICE_TASK_DEFINITION} | python -c "import sys,json; d = json.load(sys.stdin)['taskDefinition']; d.pop('status');d.pop('taskDefinitionArn');d.pop('revision');print json.dumps(d)" > tmp.json
echo 'registering new task'
aws ecs register-task-definition --cli-input-json file://tmp.json
rm tmp.json
echo 'updating service'
aws ecs update-service --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME} --task-definition ${SERVICE_TASK_DEFINITION}
echo "waiting for service ${SERVICE_NAME} to stabilize on cluster ${ECS_CLUSTER:-default}"
aws ecs wait services-stable --cluster ${ECS_CLUSTER:-default} --service ${SERVICE_NAME}
