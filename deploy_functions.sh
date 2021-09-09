#!/bin/sh

NODEJS_VERSION="nodejs14.x"
PYTHON_VERSION="python3.9"
RUBY_VERSION="ruby2.7"
JAVA_VERSION="java11"
DEFAULT_FUNCTION_SIZE=1024
FUNCTION_SUFFIX="hello-world"
POLICY_DOCUMENT=`cat assume-role-policy-document.json`

MAYBE_FUNCTION_SIZE=`echo $* | grep "function_size" | cut -d "=" -f2`
FUNCTION_SIZE=${MAYBE_FUNCTION_SIZE:-$DEFAULT_FUNCTION_SIZE}

create_lambda() {
	aws lambda get-function --function-name "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX exists already."
		echo "Updating $1 Lambda Function..."
		aws lambda update-function-code --function-name "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX" --zip-file "fileb://packages/$1.zip"
	else
		echo "$FUNCTION_SIZE-$1-$FUNCTION_SUFFIX does not exist."
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

if echo $* | grep -e "help\|man\|usage" -q; then
	echo "Usage:"
	echo "sh ./deploy_functions.sh [function_size=1024] [create_packages]\n"
	echo "Options:"
	echo "function_size		Lambda Function Memory (MB)"
	echo "create_packages		Compile and create ZIP packages"
	echo "\n\n"
	exit 0
fi
	
## Create packages
if echo $* | grep -e "create_packages" -q; then
	echo "Creating packages..."
	mkdir -p packages
	cd nodejs && zip ../packages/nodejs.zip index.js && cd ..
	cd python && zip ../packages/python.zip lambda_function.py && cd ..
	cd ruby && zip ../packages/ruby.zip lambda_function.rb && cd ..
	cd java && gradle buildZip && cd .. && cp java/build/distributions/example.zip packages/java.zip
fi

## Deploy packages
create_lambda nodejs "$NODEJS_VERSION" "index.handler"
create_lambda python "$PYTHON_VERSION" "lambda_function.lambda_handler"
create_lambda ruby "$RUBY_VERSION" "lambda_function.lambda_handler"
create_lambda java "$JAVA_VERSION" "example.Hello::handleRequest"

