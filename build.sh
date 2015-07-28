#!/bin/bash
TEST_COMMAND=$1
cd ${REPO_HOME-~/clone}
git_repo_url=`git remote -v | grep fetch | grep -o -P 'git@.*?(?=\s)'`
https_repo_url=`git remote -v | grep fetch | grep -o -P 'https://.*?(?=\s)'`
if [ $https_repo_url ]
  then
    REPO_URL=$https_repo_url
  else
    REPO_URL=`echo $git_repo_url | sed 's/:/\//g' | sed 's/^git@/https:\/\//'` 
fi
taskArn=$(aws ecs run-task --cluster ${ECS_CLUSTER:-default} --task-definition ${BUILDER_TASK_DEFINITION} --overrides \
"{ \
\"containerOverrides\": \
  [ \
    { \
    \"name\":\"build_container\", \
    \"environment\": \
      [ \
	{ \
	\"name\": \"GIT_REPO_URL\", \
	\"value\":\"$REPO_URL\" \
	}, \
	{ \
	\"name\": \"TEST_COMMAND\", \
	\"value\":\"$TEST_COMMAND\" \
	}, \
	{ \
	\"name\": \"DOCKER_REPO_NAME\", \
        \"value\":\"$DOCKER_REPO_NAME\" \
	} \
      ] \
    } \
  ] \
}" | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['taskArn']")
aws ecs wait tasks-stopped --cluster ${ECS_CLUSTER:-default} --tasks $taskArn
aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn
_() { return $(aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['containers'][0]['exitCode']"); }
_
