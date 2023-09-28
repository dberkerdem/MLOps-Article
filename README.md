# MLOps-Article
**Author:** Dağlar Berk Erdem\
**Email:** dberkerdem@gmail.com
# Agent
/agent section in the repository contains the code for building a custom ClearML agent. The agent is a Docker container that runs on a machine and executes tasks sent to it by the ClearML server. The agent is responsible for executing the tasks and reporting the results back to the server. The agent is also responsible for managing the machine's resources and ensuring that the machine is not overloaded with tasks.
## Features
- Build a custom Docker image for ClearML agents with **build_agent_image.sh**.
- Run multiple instances of ClearML agents with **run_workers.sh**.
- Automatically finds the next available name for a new worker instance if the default name is already in use.
## Prequisites
- ClearML server installed and running
- Docker installed on your machine
- Bash shell (Unix/Linux/MacOS or Git Bash on Windows)
- .env file located under/agent directory. (See .env.example for an example)
## Getting Started
Clone this repository to your local machine.
```bash
# Clone the repository, replace REPO_URL with this repository's URL
git clone [REPO_URL]
```
## Building the Docker Image
Navigate to the root of the project. Execute the following script with optional arguments:
- --image-name: Name of the Docker image to build. Default is clearml-agent-custom.
### Basic Usage
To build the Docker image with the default image name **'clearml-agent-custom'**.
```bash
# Build the Docker image
sh scripts/build_agent_image.sh
```
To build the Docker image with a custom image name (e.g. custom_image_name).
```bash
# Build the Docker image with custom image name
sh scripts/build_agent_image.sh --image-name custom_image_name
```
## Running Worker Instances
Navigate to the root of the project. Execute the **run_workers.sh** script with optional flags:
- --num-workers: Number of worker instances to run. Default is 1.
- --image-name: Name of the Docker image to use. Default is clearml-agent-custom.
### Auto Incerement Worker Names
The script **run_workers.sh** automatically finds the next available worker name if the default or last used name (clearml-agent-1, clearml-agent-2, etc.) is already in use. This ensures that new worker instances are not blocked by existing containers.\
This will allow you to use the --num-workers flag to specify the number of worker instances you wish to run, making the script more flexible and user-friendly.
### Basic Usage
Run a single worker with default settings (make sure the image is already built):
```bash
# Spin up 1 agent named clearml-agent-1 by using clearml-agent-custom Docker image
sh scripts/run_workers
```
To run multiple workers (e.g. 3) with the default settings.
```bash
# Spin up 3 agents named clearml-agent-1, clearml-agent-2, and clearml-agent-3
sh scripts/run_workers --num-workers 3
```
To run multiple workers (e.g., 3 workers) with a custom image name:
```bash
# Spin up 3 agents named clearml-agent-1, clearml-agent-2, and clearml-agent-3
# using the custom_image_name Docker image
sh scripts/run_workers --num-workers 3 --image-name custom_image_name
```
# Monitoring
## Overview
The codebase includes a monitoring solution for AWS EC2 instances using CloudWatch metrics. It fetches performance metrics such as CPU usage, disk reads/writes, and network traffic, among others. The collected data can be exported as either JSON or Parquet files.
'''
## Features
### Real-time Monitoring
Fetches metrics in real-time from AWS CloudWatch for the specified EC2 instances.
### Flexible Time Range
Specify custom time ranges or set a default time range for fetching metrics.
### Multiple Output Formats
Support for exporting metrics in both JSON and Parquet file formats.
### Configurable
Easy configuration via a YAML file. No need to hardcode values in the script.
### Granular Metrics
Fetch detailed metrics like memory usage, CPU usage, disk I/O, network activity, etc.
### Exception Handling
Includes custom exception handling for common issues like invalid time range parameters.
## Prerequisites
### AWS Account
An active AWS account is required to fetch metrics from CloudWatch.
### AWS CLI
Make sure you've installed the AWS CLI and configured it with the necessary access permissions.
### Python
Python 3.x is required to run the code. The code is tested on Python 3.8.10.
### Configuration File
A `config.yml` file with the necessary parameters like `instance_id`, `namespace`, `region`, and `period`.
### AWS Permissions
Make sure the AWS IAM role associated with your instance or user has permissions to access CloudWatch metrics.
### Environment
Jupyter Notebook environment if you are running the `monitoring.ipynb` notebook.
## Installation

1. Configure your `config.yml` file as per your needs.
2. Setup environment with the required libraries. 
    ```bash
    pip install -r requirements.txt
    ```
2. Run `monitoring.ipynb` to fetch and export the metrics, or use the `aws.py` script directly.
'''
## Components
### aws.py

- **init_client**: Initializes a boto3 client for a specific AWS service and region.
- **fetch_available_metrics**: Retrieves available metrics for a specific EC2 instance from CloudWatch.
- **validate_time_range**: Validates the time range parameters for metric fetching.
- **fetch_individual_metric**: Retrieves individual metric data.
- **fetch_metrics_of_ec2**: Orchestrates metric fetching for an EC2 instance and exports the data.
- **export_as_json**: Exports the fetched metrics to a JSON file.
- **export_as_parquet**: Exports the fetched metrics to a Parquet file.

### config.yml

This is the configuration file where you set up various parameters like 
 - instance_id 
 - namespace 
 - region 
 - period.

### monitoring.ipynb
This Jupyter Notebook provides an example use-case. It fetches and exports AWS CloudWatch metrics based on the parameters set in the `config.yml` file.
## Example Usage

You can either run the `monitoring.ipynb` notebook or use the following code snippet:

```python
from aws import fetch_metrics_of_ec2
from configs import load_config
from datetime import datetime, timedelta

# Load configurations
config = load_config("./configs/config.yml")

# Set additional parameters
config["run_id"] = "test_run"
config["export_as"] = "json"
config["start"] = datetime.utcnow() - timedelta(hours=1)
config["minutes"] = 60

# Fetch and export metrics
result_path = fetch_metrics_of_ec2(**config)
```
# LICENSE