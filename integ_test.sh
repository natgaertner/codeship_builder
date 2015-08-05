#!/bin/bash
TEST_TASK_DEFINITION=$1
ECS_CLUSTER=$2
taskArn=$(aws ecs run-task --cluster ${ECS_CLUSTER:-default} --task-definition ${TEST_TASK_DEFINITION} | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['taskArn']")
aws ecs wait tasks-stopped --cluster ${ECS_CLUSTER:-default} --tasks $taskArn
aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn
_() { return $(aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['containers'][0]['exitCode']"); }
_
