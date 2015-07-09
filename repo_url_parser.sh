#!/bin/bash
git_repo_url=`git remote -v | grep fetch | grep -o -P 'git@.*?(?=\s)'`
https_repo_url=`git remote -v | grep fetch | grep -o -P 'https://.*?(?=\s)'`
if [ $https_repo_url ]
  then
    echo $https_repo_url
  else
    echo $git_repo_url | sed 's/:/\//g' | sed 's/^git@/https:\/\//' 
fi
