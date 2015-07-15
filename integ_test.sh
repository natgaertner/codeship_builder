#!/bin/bash
SERVICE_URL=$1
taskArn=$(aws ecs run-task --task-definition ${TEST_TASK_DEFINITION} --overrides \
"{ \
\"containerOverrides\": \
  [ \
    { \
    \"name\":\"build_container\", \
    \"environment\": \
      [ \
	{ \
	\"name\": \"SERVICE_URL\", \
	\"value\":\"$SERVICE_URL\" \
	} \
      ] \
    } \
  ] \
}" | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['taskArn']")
aws ecs wait tasks-stopped --tasks $taskArn
aws ecs describe-tasks --task $taskArn
_() { return $(aws ecs describe-tasks --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['containers'][0]['exitCode']"); }
_
