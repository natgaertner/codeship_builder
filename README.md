# codeship_builder
a script to use for codeship to build containers for ecs, using ecs (magic?)

This script assumes a few things:
1. you're using codeship (thus the reference to the "~/clone" directory in the scripts)
2. you've set up a task in ECS that does your builds with a container called "build_container" that knows what to do with environment variables GIT_REPO_URL and DOCKER_REPO_NAME.
3. you've given your codeship environment AWS credentials for ECS to use, a DOCKER_REPO_NAME, and BUILD_TASK_DEFINITION name that matches the task defintion in ECS that you want to use.
4. You've synced up with a git repo that you want to build. The build scripts will attempt to get the repo url from the repo codeship checks out.
