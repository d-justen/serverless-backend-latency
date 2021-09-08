#!/bin/sh

FUNCTION_SUFFIX="hello-world"
DEFAULT_FUNCTION_SIZE=1024

if echo $* | grep -e "help\|man\|usage" -q; then
        echo "Usage:"
        echo "sh ./invoke_functions.sh [function_size=1024]\n"
        echo "Options:"
        echo "function_size             Lambda Function Memory (MB)"
        echo "\n\n"
        exit 0
fi

MAYBE_FUNCTION_SIZE=`echo $* | grep "function_size" | cut -d "=" -f2`
FUNCTION_SIZE=${MAYBE_FUNCTION_SIZE:-$DEFAULT_FUNCTION_SIZE}

for RUNTIME in "nodejs" "python" "ruby" "java";  do
	START=`date +%s%3N`
	aws lambda invoke --function-name "$FUNCTION_SIZE-$RUNTIME-$FUNCTION_SUFFIX" /dev/null > /dev/null
	END=`date +%s%3N`
	DURATION=$((END-START))

	if [ $? -eq 0 ]; then
		echo "$RUNTIME: $DURATION ms"
	else
		echo "Invocation of $RUNTIME was not successful."
	fi
done

