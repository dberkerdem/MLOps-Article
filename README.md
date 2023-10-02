# MLOps-Article
**Author:** Dağlar Berk Erdem\
**Email:** dberkerdem@gmail.com
# Getting Started
Clone this repository to your local machine.
```bash
  # Clone the repository, replace REPO_URL with this repository's URL
  git clone [REPO_URL]
  ```
# ClearML Server
In this section, ClearML server will be briefly introduced
## Setup
In this section, spinning up an ClearML server with Cloudwatch agent will be explained.
# ClearML Agent
The ClearML Agent is a powerful tool designed to streamline your machine learning operations. It takes charge of executing tasks, diligently reports results to the server, and efficiently manages machine resources to ensure optimal performance without overloading.
## Agent Plain
Dive into the /agent_plain directory to discover the core of the ClearML agent. Here, the agent operates as a Python subprocess, seamlessly integrating with your machine's environment.
### Features:
- Native Integration: Runs as a Python subprocess, ensuring smooth operation without additional overhead.
- Resource Management: Efficiently utilizes machine resources, preventing task bottlenecks.
- Real-time Reporting: Instantly communicates task results and updates to the ClearML server.
- Easy Setup: Minimal configuration required, making it suitable for quick deployments.
### Prequisites
- ClearML server running
- Bash shell (Unix/Linux/MacOS or Git Bash on Windows)
- A S3 bucket
- An IAM role with S3 read only access policy attached
- clearml.conf file located under /agent_plain directory. [See official documentation](https://clear.ml/docs/latest/docs/clearml_agent#adding-clearml-agent-to-a-configuration-file) to learn more about creating configuration file.
### Setup
See [Automated Deployment of ClearML Agents](#automated-deployment-of-clearml-agents) to learn more about how to spin up EC2 instances using terraform.


## Agent Docker
Explore the /agent_docker directory for a containerized experience. This custom ClearML agent is encapsulated within a Docker container, ensuring consistent performance as it executes tasks dispatched by the ClearML server.
### Features
- Containerized Execution: Runs within a Docker container, ensuring a consistent environment across different machines.
- Scalability: Easily deploy multiple instances to handle increasing workloads.
- Isolated Environment: Prevents dependency conflicts and ensures task consistency.
- Customizable: Modify and build your custom Docker image tailored to specific requirements.
- Build a custom Docker image for ClearML agents with **build_agent_image.sh**.
- Run multiple instances of ClearML agents with **run_workers.sh**.
- Automatically finds the next available name for a new worker instance if the default name is already in use.
### Prequisites
- Docker installed on your machine
- Bash shell (Unix/Linux/MacOS or Git Bash on Windows)
- .env file located under /agent_docker directory. (See .env.example for an example)
### Setup
#### Building the Docker Image
Navigate to the root of the project. Execute the **build_agent_image.sh** script with optional arguments:
- --image-name: Name of the Docker image to build. Default is clearml-agent-custom.
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
#### Running Worker Instances
Navigate to the root of the project. Execute the **run_workers.sh** script with optional flags:
- --agent-mode: Mode of agent to be run options are agent_plain and agent_docker. Default is agent_plain.
- --num-workers: Number of worker instances to run. Default is 1.
- --image-name: Name of the Docker image to use. Default is clearml-agent-custom.
#### Auto Incerement Worker Names
The script **run_workers.sh** automatically finds the next available worker name if the default or last used name (clearml-agent-1, clearml-agent-2, etc.) is already in use. This ensures that new worker instances are not blocked by existing containers.\
This will allow you to use the --num-workers flag to specify the number of worker instances you wish to run, making the script more flexible and user-friendly.
### Basic Usage
Run a single worker with default settings (make sure the image is already built):
```bash
# Spin up 1 agent named clearml-agent-1 by using clearml-agent-custom Docker image
sh scripts/run_workers --agent-mode agent_docker
```
To run multiple workers (e.g. 3) with the default settings.
```bash
# Spin up 3 agents named clearml-agent-1, clearml-agent-2, and clearml-agent-3
sh scripts/run_workers --agent-mode agent_docker --num-workers 3
```
To run multiple workers (e.g., 3 workers) with a custom image name:
```bash
# Spin up 3 agents named clearml-agent-1, clearml-agent-2, and clearml-agent-3
# using the custom_image_name Docker image
sh scripts/run_workers --num-workers 3 --image-name custom_image_name
```

### Agent Docker with Terraform
The agent_docker directory not only provides a containerized ClearML agent but also supports infrastructure as code (IaC) deployments using Terraform. This allows you to automate the provisioning of AWS EC2 instances tailored for the ClearML agent.

#### What it does:
1. Backend Configuration: Uses a local backend to store the Terraform state.
2. AWS Provider Setup: Configures the AWS provider with the specified region.
3. Environment Variables: Reads the .env file from the parent directory.
4. EC2 Instance Creation: Provisions an AWS EC2 instance with:
    - Specified AMI and instance type.
    - EBS block device configuration.
    - User data for instance initialization, which includes:
    - Updating the system.
    - Installing Docker and Git.
    - Cloning the repository.
    - Setting up the ClearML agent environment.
    - Pulling the Docker image and running the ClearML agent container.
5. Tagging: Tags the EC2 instance for easier identification.
See Automated Deployment section

See [Automated Deployment of ClearML Agents](#automated-deployment-of-clearml-agents) to learn more about how to spin up EC2 instances using terraform.

## Automated Deployment of ClearML Agents
We provide a script to automate the deployment of ClearML agents on AWS using Terraform.\
This script supports both the plain and Dockerized versions of the ClearML agent.

### Prerequisites:
- Ensure you have Terraform installed.
- AWS credentials set up, either as environment variables or in the AWS credentials file.
- Bash shell (Unix/Linux/MacOS or Git Bash on Windows).

### How to Use the Deployment Script:
1. Navigate to the Script Directory:
  ```bash
  cd scripts
  ```
2. Make the Script Executable:
  ```bash
  chmod +x spin_up_agent.sh
  ```
3. Deploy the ClearML Agents:
You can specify the mode (agent_plain or agent_docker) and the number of agents to deploy.

**For deploying a single plain agent:**
```bash
./spin_up_agent.sh --agent-mode agent_plain --num-agents 1
```
**For deploying multiple Dockerized agents (e.g., 3 agents):**
```bash
./script_name.sh --agent-mode agent_docker --num-agents 3
```
The script will validate the Terraform configuration for each agent before deploying.\
Terraform state files for each agent are stored in separate directories based on the agent mode and instance name.

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