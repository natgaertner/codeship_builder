#!/bin/bash
cd ${REPO_HOME-~/clone}
git_repo_url=`git remote -v | grep fetch | grep -o -P 'git@.*?(?=\s)'`
https_repo_url=`git remote -v | grep fetch | grep -o -P 'https://.*?(?=\s)'`
if [ $https_repo_url ]
  then
    REPO_URL=$https_repo_url
  else
    REPO_URL=`echo $git_repo_url | sed 's/:/\//g' | sed 's/^git@/https:\/\//'` 
fi
taskArn=$(aws ecs run-task --task-definition ${BUILDER_TASK_DEFINITION} --overrides \
"{ \
\"containerOverrides\": \
  [ \
    { \
    \"name\":\"build_java_example\", \
    \"environment\": \
      [ \
	{ \
	\"name\": \"GIT_REPO_URL\", \
	\"value\":\"$REPO_URL\" \
	}, \
	{ \
	\"name\": \"DOCKER_REPO_NAME\", \
        \"value\":\"$DOCKER_REPO_NAME\" \
	} \
      ] \
    } \
  ] \
}" | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['taskArn']")
aws ecs wait tasks-stopped --tasks $taskArn
aws ecs describe-tasks --task $taskArn
_() { return $(aws ecs describe-tasks --task $taskArn | python -c "import sys, json; print json.load(sys.stdin)['tasks'][0]['containers'][0]['exitCode']"); }
_
