# Serverless Backend Latency

Tool to measure the (cold-start-)latency of Lambda Functions with different runtimes. Provides sample applications for nodeJs, Python, Ruby, and Java.

1. Run `aws configure` to provide credentials and target region
2. `sh deploy_functions.sh`
3. Start EC2 instance in target region and run `sh invoke_functions.sh` from within

## Dependencies
- AWS CLI
- Gradle

