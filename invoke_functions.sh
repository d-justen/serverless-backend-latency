#!/bin/sh

DEFAULT_FUNCTION_SIZE=1024
FUNCTION_SIZE=${1:-$DEFAULT_FUNCTION_SIZE}

for RUNTIME in "nodejs" "python" "ruby" "java";  do
	START=`date +%s%3N`
	aws lambda invoke --function-name "$FUNCTION_SIZE-$RUNTIME-hello-world" /dev/null > /dev/null
	END=`date +%s%3N`
	DURATION=$((END-START))

	if [ $? -eq 0 ]; then
		echo "$RUNTIME: $DURATION ms"
	else
		echo "Invocation of $RUNTIME was not successful."
	fi
done

