#!/bin/bash
pip install awscli
aws configure set aws_access_key_id ${AWS_ACCESS_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_KEY}
aws configure set region ${AWS_REGION}
