#!/bin/bash
CF_DEPLOY_CLUSTER_STACK=${CF_DEPLOY_CLUSTER_STACK:-$CF_DEPLOY_STACK}

if [ $CF_DEPLOY_CLUSTER_STACK -a $LOGICAL_CLUSTER_NAME ]
then
  ECS_CLUSTER=`get_resource $CF_BUILD_STACK $LOGICAL_CLUSTER_NAME`
else
  ECS_CLUSTER=$1
fi
echo "ECS_CLUSTER: $ECS_CLUSTER"

if [ $CF_DEPLOY_STACK -a $LOGICAL_TEST_TASK_NAME ]
then
  TEST_TASK_DEFINITION=`get_resource $CF_DEPLOY_STACK $LOGICAL_TEST_TASK_NAME | grep -Po '(?<=task-definition/).+'`
else
  TEST_TASK_DEFINITION=$2
fi
echo "TEST_TASK_DEFINITION: $TEST_TASK_DEFINITION"

taskArn=$(aws ecs run-task --cluster ${ECS_CLUSTER:-default} --task-definition ${TEST_TASK_DEFINITION} | jq -r .tasks[0].taskArn)
aws ecs wait tasks-stopped --cluster ${ECS_CLUSTER:-default} --tasks $taskArn
aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn
_() { return $(aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn | jq -r .tasks[0].containers[0].exitCode); }
_
