#!/bin/bash
get_resource () {
  echo `aws cloudformation describe-stack-resource --stack-name $1 --logical-resource-id $2 | jq -r .StackResourceDetail.PhysicalResourceId`
}
