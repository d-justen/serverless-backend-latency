#!/usr/bin/python3

import base64
import boto3
import getopt
import re
import sys
import time

# TODO: Parse function size from args
function_size = "1024"
runtimes = ["nodejs", "python", "ruby", "java"]
function_suffix = "hello-world"

client = boto3.client('lambda')

for runtime in runtimes:
    function_name = "%s-%s-%s" % (function_size, runtime, function_suffix)

    start = time.time() 
    response = client.invoke(
            FunctionName=(function_name),
            LogType="Tail"
    )
    end = time.time()
    duration = (end - start) * 1000
    print("%s: %s ms" % (runtime, duration))

    log_result = base64.b64decode(response["LogResult"])
    match = re.search("(?<=Init Duration: )\S*", str(log_result))
    
    init_duration = ""
    was_cold = False
    if match:
        init_duration = match.group(0)
        was_cold = True

    with open("results.csv", "a+") as result_file:
        result_file.write("%s,%s,%s,%s,%s\n" % (runtime, function_size, was_cold, duration, init_duration))

