#!/bin/bash
export REPO_URL=`./repo_url_parser.sh`
taskArn=$(aws ecs run-task --task-definition ${BUILDER_TASK_DEFINITION} --overrides {"containerOverrides":[{"name":"build_java_example","environment": [{"name": "GIT_REPO_URL","value":$REPO_URL},{"name": "DOCKER_REPO_NAME","value":$DOCKER_REPO_NAME}]}]} | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['taskArn']") && aws ecs wait tasks-stopped --tasks $taskArn
_() { return $(aws ecs describe-tasks --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['containers'][0]['exitCode']"); } && _
