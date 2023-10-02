#!/bin/bash

# Ouput all log
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Set environment variables
cat > /etc/profile.d/.env.example.sh <<EOF
${env_variables_content}
EOF

chmod +x /etc/profile.d/.env.example.sh

# Install CWAgent
yum install -y amazon-cloudwatch-agent

# Use cloudwatch config from SSM
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${ssm_cloudwatch_config} -s

systemctl start amazon-cloudwatch-agent

echo 'Done initialization'
