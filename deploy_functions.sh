#!/bin/sh

# Packages and deploys Lambda Functions
mkdir -p packages

NODEJS_VERSION="nodejs14.x"
PYTHON_VERSION="python3.9"
RUBY_VERSION="ruby2.7"
JAVA_VERSION="java11"

DEFAULT_FUNCTION_SIZE=1024
FUNCTION_SIZE=${1:-$DEFAULT_FUNCTION_SIZE}
FUNCTION_SUFFIX="hello-world"
POLICY_DOCUMENT=`cat assume-role-policy-document.json`

create_lambda() {
	aws lambda get-function --function-name "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "Updating $1 Lambda Function..."
		aws lambda update-function-code --function-name "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX" --zip-file "fileb://packages/$1.zip"
	else
		echo "Creating $1 Lambda Function..."
		
		aws iam get-role --role-name "$FUNCTION_SUFFIX" > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			aws iam create-role --role-name "$FUNCTION_SUFFIX" --assume-role-policy-document "$POLICY_DOCUMENT"
			aws iam attach-role-policy --role-name "$FUNCTION_SUFFIX" --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
			sleep 6s
		fi

		local ARN=`aws iam get-role --role-name "$FUNCTION_SUFFIX" | jq -r '.Role.Arn'` 

		aws lambda create-function --function-name "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX" --zip-file "fileb://packages/$1.zip" --runtime "$2" --role "$ARN" --memory-size "$FUNCTION_SIZE" --handler "$3"
	fi
}

## Package and deploy nodeJS
cd nodejs && zip ../packages/nodejs.zip index.js && cd ..
create_lambda nodejs "$NODEJS_VERSION" "index.handler"

## Package and deploy Python
cd python && zip ../packages/python.zip lambda_function.py && cd ..
create_lambda python "$PYTHON_VERSION" "lambda_function.lambda_handler"

## Package and deploy Ruby
cd ruby && zip ../packages/ruby.zip lambda_function.rb && cd ..
create_lambda ruby "$RUBY_VERSION" "lambda_function.lambda_handler"

## Package and deploy Java
cd java && gradle buildZip && cd .. && cp java/build/distributions/example.zip packages/java.zip
create_lambda java "$JAVA_VERSION" "example.Hello::handleRequest"

