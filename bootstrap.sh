#!/bin/bash

set -e

ENV=$1
ACCOUNT_ID=$2

if [ -z "$ENV" ] || [ -z "$ACCOUNT_ID" ]; then
  echo "Usage: ./bootstrap.sh <development|homologation|production> <AWS_ACCOUNT_ID>"
  exit 1
fi

#AWS_REGION="us-east-1"

echo "Deploying VPC..."
aws cloudformation deploy \
  --template-file cloudformation/vpc.yml \
  --stack-name ${ENV}-vpc \
  --parameter-overrides \
    ParameterKey=Environment,ParameterValue=${ENV} \
  --region ${AWS_REGION} \
  --capabilities CAPABILITY_NAMED_IAM

VPC_ID=$(aws cloudformation describe-stacks \
  --stack-name ${ENV}-vpc \
  --region ${AWS_REGION} \
  --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" \
  --output text)

SUBNET_IDS=$(aws cloudformation describe-stacks \
  --stack-name ${ENV}-vpc \
  --region ${AWS_REGION} \
  --query "Stacks[0].Outputs[?OutputKey=='PublicSubnetIds'].OutputValue" \
  --output text)

echo "Deploying ALB..."
aws cloudformation deploy \
  --template-file cloudformation/alb.yml \
  --stack-name ${ENV}-alb \
  --parameter-overrides \
    ParameterKey=Environment,ParameterValue=${ENV} \
    ParameterKey=VpcId,ParameterValue=${VPC_ID} \
    ParameterKey=PublicSubnetIds,ParameterValue=${SUBNET_IDS} \
  --region ${AWS_REGION} \
  --capabilities CAPABILITY_NAMED_IAM

echo "Deploying IAM Roles..."
aws cloudformation deploy \
  --template-file cloudformation/iam-roles.yml \
  --stack-name ${ENV}-iam \
  --parameter-overrides \
    ParameterKey=Environment,ParameterValue=${ENV} \
    ParameterKey=AccountId,ParameterValue=${ACCOUNT_ID} \
  --region ${AWS_REGION} \
  --capabilities CAPABILITY_NAMED_IAM

echo "Bootstrap completed for $ENV environment."
