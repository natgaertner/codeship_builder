#!/bin/bash
TEST_COMMAND=$1
cd ${REPO_HOME-~/clone}
git_repo_url=`git remote -v | grep fetch | grep origin | grep -o -P 'git@.*?(?=\s)'`
https_repo_url=`git remote -v | grep fetch | grep origin | grep -o -P 'https://.*?(?=\s)'`
if [ $git_repo_url ]
  then
    #convert to https from git
    #REPO_URL=`echo $git_repo_url | sed 's/:/\//g' | sed 's/^git@/https:\/\//'` 
    REPO_URL=$git_repo_url
  else
    #convert to git from https
    REPO_URL=`echo $https_repo_url | sed 's/https:\/\//git@/g' | sed 's/github\.com\//github.com:/g'`

fi
echo $REPO_URL
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

stopped=$(aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['lastStatus']")
{ while [ $stopped != 'STOPPED' ]; do sleep 10; stopped=$(aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['lastStatus']"); printf '.'; done; } | timeout 1200 cat

aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn
_() { return $(aws ecs describe-tasks --cluster ${ECS_CLUSTER:-default} --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['containers'][0]['exitCode']"); }
_
